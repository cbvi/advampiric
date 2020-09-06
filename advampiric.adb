with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.Bounded;
with Ada.Text_IO.Bounded_IO;
with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Wide_Wide_Fixed;
with Ada.IO_Exceptions;

procedure advampiric is
   package IO renames Ada.Text_IO;
   package EIO renames Ada.IO_Exceptions;

   package BS
      is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 128);

   package BIO
      is new Ada.Text_IO.Bounded_IO (Bounded => BS);

   package Name_Vectors is new Ada.Containers.Indefinite_Vectors
      (Index_Type => Natural,
       Element_Type => Wide_Wide_String);

   type IO_Status is (
      Ok, Status_Error, Mode_Error, Name_Error, Use_Error,
      Device_Error, End_Error, Data_Error, Layout_Error
   );

   type Log_Type is
      record
         Id          : Natural;
         Name        : BS.Bounded_String;
         Path        : BS.Bounded_String;
         Important   : Name_Vectors.Vector;
      end record;

   type Log_List is array (1 .. 2) of Log_Type;

   function Get_Logs return Log_List;
   function Is_Important (Msg : in Wide_Wide_String;
                          Names : in Name_Vectors.Vector)
      return Boolean;

   procedure Open_File (File_Name   : in     String;
                        File        : in out Ada.Wide_Wide_Text_IO.File_Type;
                        File_Status :    out IO_Status);

   procedure Open_File (File_Name   : in     String;
                        File        : in out Ada.Wide_Wide_Text_IO.File_Type;
                        File_Status :    out IO_Status)
   is
   begin
      Ada.Wide_Wide_Text_IO.Open (
         File => File,
         Mode => Ada.Wide_Wide_Text_IO.In_File,
         Name => File_Name,
         Form => "WCEM=8"
      );
      File_Status := Ok;
   exception
      when EIO.Status_Error =>
         File_Status := Status_Error;
      when EIO.Mode_Error =>
         File_Status := Mode_Error;
      when EIO.Name_Error =>
         File_Status := Name_Error;
      when EIO.Use_Error =>
         File_Status := Use_Error;
      when EIO.Device_Error =>
         File_Status := Device_Error;
      when EIO.End_Error =>
         File_Status := End_Error;
      when EIO.Data_Error =>
         File_Status := Data_Error;
      when EIO.Layout_Error =>
         File_Status := Layout_Error;
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

   File : Ada.Wide_Wide_Text_IO.File_Type;
   Status : IO_Status;
begin
   Ada.Wide_Wide_Text_IO.Put_Line ("test");

   for L of Logs loop
      BIO.Put_Line (L.Name);

      if Is_Important ("XX:XX <Name1> it works", L.Important) then
         IO.Put_Line ("it works");
      end if;

      Open_File (BS.To_String (L.Path), File, Status);
      case Status is
         when Ok =>
            loop
               declare
                  Line : Wide_Wide_String (1 .. 1024);
                  Last : Natural;
               begin
                  Ada.Wide_Wide_Text_IO.Get_Line (File, Line, Last);
                  if Is_Important (Line (1 .. Last), L.Important) then
                     Ada.Wide_Wide_Text_IO.Put_Line (Line (1 .. Last));
                  end if;
               exception
                  when EIO.End_Error => exit;
               end;
            end loop;
            Ada.Wide_Wide_Text_IO.Close (File);
         when others =>
            IO.Put_Line (IO_Status'Image (Status));
      end case;
   end loop;

end advampiric;
