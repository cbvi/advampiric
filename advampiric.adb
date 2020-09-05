with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.Bounded;
with Ada.Text_IO.Bounded_IO;
with Ada.Containers.Indefinite_Vectors;

procedure advampiric is
   package IO renames Ada.Text_IO;

   package BS
      is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 128);

   package BIO
      is new Ada.Text_IO.Bounded_IO (Bounded => BS);

   package Name_Vectors is new Ada.Containers.Indefinite_Vectors
      (Index_Type => Natural,
       Element_Type => String);

   type Log_Type is
      record
         Id          : Natural;
         Name        : BS.Bounded_String;
         Path        : BS.Bounded_String;
         Important   : Name_Vectors.Vector;
      end record;

   type Log_List is array (1 .. 2) of Log_Type;

   function Get_Logs return Log_List;

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

   Logs : constant Log_List := Get_Logs;

begin
   Ada.Wide_Wide_Text_IO.Put_Line ("test");

   for L of Logs loop
      BIO.Put_Line (L.Path);

      for N of L.Important loop
         IO.Put_Line (N);
      end loop;
   end loop;
end advampiric;
