with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.Bounded;
with Ada.Text_IO.Bounded_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Wide_Wide_Fixed;
with Ada.IO_Exceptions;
with Ada.Exceptions;

procedure advampiric is
   package IO renames Ada.Text_IO;
   package EIO renames Ada.IO_Exceptions;
   package EX renames Ada.Exceptions;

   package BS
      is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 128);

   package BIO
      is new Ada.Text_IO.Bounded_IO (Bounded => BS);

   package Name_Vectors is new Ada.Containers.Indefinite_Vectors
      (Index_Type => Natural,
       Element_Type => Wide_Wide_String);

   type IO_Error is (
      Status_Error, Mode_Error, Name_Error, Use_Error,
      Device_Error, End_Error, Data_Error, Layout_Error
   );

   type Result_Status is (Ok, Err);

   type Result (X : Result_Status := Ok) is record
      case X is
         when Ok =>
            null;
         when Err =>
            Error : IO_Error;
            Msg : String (1 .. 200);
      end case;
   end record;

   type Log_Type is
      record
         Id          : Natural;
         Name        : BS.Bounded_String;
         Path        : BS.Bounded_String;
         Important   : Name_Vectors.Vector;
      end record;

   type Log_List is array (1 .. 2) of Log_Type;

   function Ex_Msg (E : Ada.Exceptions.Exception_Occurrence) return String;

   function Ex_Msg (E : Ada.Exceptions.Exception_Occurrence) return String is
      Msg : constant String := EX.Exception_Message (E);
      Pad : constant String (1 .. 200) :=
         Msg & (1 .. 200 - Msg'Length => Character'Val (0));
   begin
      return Pad;
   end Ex_Msg;

   function Get_Logs return Log_List;
   function Is_Important (Msg : in Wide_Wide_String;
                          Names : in Name_Vectors.Vector)
      return Boolean;

   function Open_File (File_Name : in String) return Result;

   function Open_File (File_Name : in String) return Result is
      File : Ada.Wide_Wide_Text_IO.File_Type;
   begin
      begin
         Ada.Wide_Wide_Text_IO.Open (
            File => File,
            Mode => Ada.Wide_Wide_Text_IO.In_File,
            Name => File_Name,
            Form => "WCEM=8"
         );
      exception
         when E : EIO.Status_Error =>
            return (Err, Status_Error, Ex_Msg (E));
         when E : EIO.Mode_Error =>
            return (Err, Mode_Error, Ex_Msg (E));
         when E : EIO.Name_Error =>
            return (Err, Name_Error, Ex_Msg (E));
         when E : EIO.Use_Error =>
            return (Err, Use_Error, Ex_Msg (E));
         when E : EIO.Device_Error =>
            return (Err, Device_Error, Ex_Msg (E));
         when E : EIO.End_Error =>
            return (Err, End_Error, Ex_Msg (E));
         when E : EIO.Data_Error =>
            return (Err, Data_Error, Ex_Msg (E));
         when E : EIO.Layout_Error =>
            return (Err, Layout_Error, Ex_Msg (E));
      end;
      return (X => Ok);
   end Open_File;

   function Get_Logs return Log_List is
      Logs : constant Log_List := ((
         Id => 1,
         Name => BS.To_Bounded_String ("log2"),
         Path => BS.To_Bounded_String ("log2.log"),
         Important => Name_Vectors."&"("Name1", "Name2")
      ), (
         Id => 2,
         Name => BS.To_Bounded_String ("log1"),
         Path => BS.To_Bounded_String ("log1.log"),
         Important => Name_Vectors.To_Vector ("Name3", 1)
      ));
   begin
      return Logs;
   end Get_Logs;

   pragma Pure_Function (Get_Logs);

   function Is_Important (Msg : in Wide_Wide_String;
                          Names : in Name_Vectors.Vector)
      return Boolean is
   begin
      for N of Names loop
         if Ada.Strings.Wide_Wide_Fixed.Index (Msg, N) /= 0 then
            return True;
         end if;
      end loop;
      return False;
   end Is_Important;

   pragma Pure_Function (Is_Important);

   Logs : constant Log_List := Get_Logs;

   Res : Result;

begin
   Ada.Wide_Wide_Text_IO.Put_Line ("test");

   for L of Logs loop
      BIO.Put_Line (L.Name);

      if Is_Important ("XX:XX <Name1> it works", L.Important) then
         IO.Put_Line ("it works");
      end if;

      Res := Open_File (BS.To_String (L.Path));
      case Res.X is
         when Ok =>
            IO.Put_Line ("OK!");
         when others =>
            IO.Put_Line (Res.Msg);
      end case;
   end loop;

end advampiric;
