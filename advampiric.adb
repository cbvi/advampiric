with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;
with Ada.Strings.Bounded;
with Ada.Text_IO.Bounded_IO;

procedure advampiric is
   type Name_Access is access constant String;
   type Name_List is array (Positive range <>) of Name_Access;

   package IO renames Ada.Text_IO;

   package BS
      is new Ada.Strings.Bounded.Generic_Bounded_Length (Max => 128);

   package BIO
      is new Ada.Text_IO.Bounded_IO (Bounded => BS);

   type Log (Important_Count : Natural) is
      record
         Id          : Natural;
         Name        : BS.Bounded_String;
         Path        : BS.Bounded_String;
         Important   : Name_List (1 .. Important_Count);
      end record;

   Dfly : Log := (
      Id => 1,
      Name => BS.To_Bounded_String ("log2"),
      Path => BS.To_Bounded_String ("log2.log"),
      Important => (
         new String'("Name1"),
         new String'("Name2")
      ),
      Important_Count => 2
   );

   Myr : Log := (
      Id => 2,
      Name => BS.To_Bounded_String ("log1"),
      Path => BS.To_Bounded_String ("log1.log"),
      Important => (
         1 => new String'("Name3")
      ),
      Important_Count => 1
   );
begin
   Ada.Wide_Wide_Text_IO.Put_Line ("test");

   BIO.Put_Line (Myr.Name);

   for I in Dfly.Important'Range loop
      IO.Put_Line (Dfly.Important (I).all);
   end loop;

   for I in Myr.Important'Range loop
      IO.Put_Line (Myr.Important (I).all);
   end loop;
end advampiric;