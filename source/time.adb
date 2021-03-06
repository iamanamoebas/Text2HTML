--------------------------------------------------------------------------------
--                                                                            --
-- Copyright (C) 2004, RISC OS Ada Library (RASCAL) developers.               --
--                                                                            --
-- This library is free software; you can redistribute it and/or              --
-- modify it under the terms of the GNU Lesser General Public                 --
-- License as published by the Free Software Foundation; either               --
-- version 2.1 of the License, or (at your option) any later version.         --
--                                                                            --
-- This library is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU           --
-- Lesser General Public License for more details.                            --
--                                                                            --
-- You should have received a copy of the GNU Lesser General Public           --
-- License along with this library; if not, write to the Free Software        --
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA    --
--                                                                            --
--------------------------------------------------------------------------------

-- $Author$
-- $Date$
-- $Revision$

-- StrongEd$WrapWidth=256
-- StrongEd$Mode=Ada
--

with OS;
with kernel;                use Kernel;
with Utility;               use Utility;
with Memory;                use Memory;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings;           use Ada.Strings;

with Interfaces.C;            use Interfaces.C;
with System.Storage_Elements; use System.Storage_Elements;
with Reporter;

package body Time is

   Territory_ConvertDateAndTime       : constant := 16#4304B#;
   Territory_ConvertTimeToUTCOrdinals : constant := 16#43049#;
   OS_Word                            : constant := 16#07#;

   --

   function Get_Current_Time (Centi : in boolean := false) return string is
   
   register   : aliased Kernel.swi_regs;
   time       : array(0..4) of Character;
   blk        : array(0..8) of Integer;
   hours : String(1..2);
   mins  : String(1..2);
   secs  : String(1..2);
   centisecs : String(1..2);
   
   begin
     register.r(0) := 14;
     register.r(1) := Adr_To_Int(time'Address);
     PutByte (3,time'Address);
     Kernel.swi(OS_Word, register'Access, register'Access);
     register.r(1) := Adr_To_Int(time'Address);
     register.r(2) := Adr_To_Int(blk'Address);
     Kernel.swi (Territory_ConvertTimeToUTCOrdinals, register'Access,
                 register'Access);
     Ada.Strings.Fixed.Move (Source => intstr(blk(3)),
                             Target => hours,
                             Justify => Right,
                             Pad => Character'Val(48));
     Ada.Strings.Fixed.Move (Source => intstr(blk(2)),
                             Target => mins,
                             Justify => Right,
                             Pad => Character'Val(48));
     Ada.Strings.Fixed.Move (Source => intstr(blk(1)),
                             Target => secs,
                             Justify => Right,
                             Pad => Character'Val(48));
     if centi then
       Ada.Strings.Fixed.Move (Source => intstr(blk(0)),
                               Target => centisecs,
                               Justify => Right,
                               Pad => Character'Val(48));
       return hours&":"&mins&":"&secs&":"&centisecs;
     else
       return hours&":"&mins&":"&secs;
     end if;
   end Get_Current_Time;

   --   

   function Get_Date (Format : in string := "%ce%yr-%mn-%dy") return string is
   
      Register   : aliased Kernel.swi_regs;
      Time       : array(0..4) of Character;
      Blk        : array(0..100) of Character;
      Format_0   : string := Format & ASCII.NUL;
      Error      : OSError_Access;
   begin
      Time(0) := Character'Val(3);
      Register.R(0) := 14;
      Register.R(1) := Adr_To_Int(Time(0)'Address);
      --PutByte (3,Time'Address);
      
      Kernel.swi(OS_Word, Register'Access, Register'Access);

      Register.R(0) := -1;
      Register.R(1) := Adr_To_Int(Time'Address);
      Register.R(2) := Adr_To_Int(Blk'Address);
      Register.R(3) := 100;
      Register.R(4) := Adr_To_Int(Format_0'Address);
      
      Error := Kernel.swi (Territory_ConvertDateAndTime, Register'Access, register'Access);
      if Error /= null then
         pragma Debug(Reporter.Report("Time.Get_Date: " & To_Ada(Error.ErrMess)));
         OS.Raise_Error(Error);
      end if;

      return MemoryToString(int_To_Adr(Register.R(0)),0);

   end Get_Date;

   --

   function Read_MonotonicTime return Integer is

      OS_ReadMonotonicTime : constant := 16#042#;
      Register             : aliased Kernel.swi_regs;
      Error                : OSError_Access;
   begin
      Error := Kernel.swi (OS_ReadMonotonicTime, Register'Access, register'Access);
      if Error /= null then
         pragma Debug(Reporter.Report("Time.Get_MonotonicTime: " & To_Ada(Error.ErrMess)));
         OS.Raise_Error(Error);
      end if;
      return Integer(Register.R(0));
   end Read_MonotonicTime;

   --

end Time;
