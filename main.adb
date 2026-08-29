with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Dispatching;
with Ada.Real_Time;        use Ada.Real_Time;

procedure Main is

   -- 自訂強型別樓層範圍
   type Floor_Type is range 1 .. 10;

   -- 定義Task規格
   task Elevator_Task is
      entry Move_To (Target : Floor_Type);
      entry Stop;
   end Elevator_Task;

   -- 定義Task實作
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
               Put_Line ("[Elevator] Moving to" & Target_Floor'Image & " Floor");

            -- 模擬電梯移動過程
               while Current_Floor /= Target_Floor loop
                  delay 1.0; -- 移動每層樓耗時 1 秒

                  if Current_Floor < Target_Floor then
                     Current_Floor := Current_Floor + 1;
                     Put_Line ("[Elevator] uping... Now Floor:" & Current_Floor'Image);
                  else
                     Current_Floor := Current_Floor - 1;
                     Put_Line ("[Elevator] downing... Now Floor:" & Current_Floor'Image);
                  end if;
               end loop;
               Put_Line ("[Elevator] Get to" & Current_Floor'Image & " Floor,Door Open");
            end Move_To;

         or
            -- 接收停止訊號
            accept Stop do
               Is_Running := False;
            end Stop; 
            Put_Line ("[Elevator] System closed");
         end select;
      end loop;
   end Elevator_Task;

   Input_Choice : Integer;
   User_Target  : Floor_Type;
-- 主程式執行區塊
begin
   loop
      New_Line;
      Put_Line ("=== Control Menu ===");
      Put_Line ("1-10 : Enter the target floor");
      Put_Line ("0    : Close the elevator and exit the program.");
      Put ("Please enter selection.:");
      
      Get (Input_Choice);

      if Input_Choice = 0 then
         Put_Line ("[Main] Sending stop signal to elevator...");
         Elevator_Task.Stop;
         exit; -- 跳出主程式迴圈
      elsif Input_Choice >= 1 and Input_Choice <= 10 then
         User_Target := Floor_Type (Input_Choice);
         Put_Line ("[Main] Delivery command: Go to" & User_Target'Image & " Floor");
         
         -- 呼叫電梯 Task，此時 Main 會等待電梯完成移動才會繼續回到選單
         Elevator_Task.Move_To (User_Target);
      else
         Put_Line ("[Error] Invalid floor number! Please enter a number between 1 and 10.");
      end if;
   end loop;

   Put_Line ("[Main] Program exited.");
end Main;