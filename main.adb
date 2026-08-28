with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Dispatching;
with Ada.Real_Time;        use Ada.Real_Time;

procedure Main is

   -- 1. 自訂強型別樓層範圍 (1 到 10 樓)
   type Floor_Type is range 1 .. 10;

   -- 2. 定義 Task 規格 (Specification)
   task Elevator_Task is
      entry Move_To (Target : Floor_Type);
      entry Stop;
   end Elevator_Task;

   -- 3. 定義 Task 實作 (Body)
   task body Elevator_Task is
      Current_Floor : Floor_Type := 1;
      Target_Floor  : Floor_Type := 1;
      Is_Running    : Boolean    := True;
   begin
      Put_Line ("[Elevator] Ready at Floor 1");

      while Is_Running loop
         select
            -- 接收目標樓層指令
            accept Move_To (Target : Floor_Type) do
               Target_Floor := Target;
            end Move_To;

            Put_Line ("[Elevator] Moving to" & Target_Floor'Image & " Floor");

            -- 模擬電梯移動過程
            while Current_Floor /= Target_Floor loop
               delay 1.0; -- 模擬移動每層樓耗時 1 秒

               if Current_Floor < Target_Floor then
                  Current_Floor := Current_Floor + 1;
                  Put_Line ("[Elevator] uping... Now Floor:" & Current_Floor'Image);
               else
                  Current_Floor := Current_Floor - 1;
                  Put_Line ("[Elevator] downing... Now Floor:" & Current_Floor'Image);
               end if;
            end loop;

            Put_Line ("[Elevator] Get to" & Current_Floor'Image & " Floor,Door Open");

         or
            -- 接收停止訊號
            accept Stop do
               Is_Running := False;
            end Stop;
            Put_Line ("[Elevator] System closed");
         end select;
      end loop;
   end Elevator_Task;

-- 主程式執行區塊
begin
   Put_Line ("[Main] Delivery command:Go to 5 Floor");
   Elevator_Task.Move_To (5);

   delay 2.0;

   Put_Line ("[Main] Delivery command:Go to 2 Floor");
   Elevator_Task.Move_To (2);

   Put_Line ("[Main] Delivery command:Close the elevator");
   Elevator_Task.Stop;
end Main;