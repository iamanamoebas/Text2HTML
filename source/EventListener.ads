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

--
-- @filename EventListener.ads
-- @author Bent Bracke
-- @date 20.12.2003
-- @version 1.0
-- @brief Interface for event listeners.
-- 
-- History: 
-- 

package EventListener is

   type Event_Type is (Wimp,Message,Toolbox);
   type Event_Listener (K : Event_Type) is abstract tagged record
   Kind : Event_Type := K;
   end record;

   type Event_Pointer is access all Event_Listener'Class;

   procedure Handle (The : in Event_Listener) is abstract;

end EventListener;
