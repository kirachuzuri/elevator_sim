with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Dispatching;
with Ada.Real_Time;        use Ada.Real_Time;

procedure Main is

   -- 自訂強型別樓層範圍
   type Floor_Type is range 1 .. 10;
   -- 記錄哪些樓層被按了 (True 表示該樓層有請求)
   type Request_Array is array (Floor_Type) of Boolean;

   -- 定義Task規格
   task Elevator_Task is
      entry Move_To (Target : Floor_Type);
      entry Stop;
   end Elevator_Task;

   -- 定義Task實作
   task body Elevator_Task is
      Current_Floor : Floor_Type    := 1;
      Is_Running    : Boolean       := True;
      Requests      : Request_Array := (others => False);
      Direction     : Integer       := 0; -- 1: 向上, -1: 向下, 0: 靜止

      -- 檢查是否還有任何未處理的樓層請求
      function Has_Requests return Boolean is
      begin
         for F in Floor_Type loop
            if Requests(F) then
               return True;
            end if;
         end loop;
         return False;
      end Has_Requests;

   begin
      Put_Line ("[Elevator] Ready at Floor 1");

      while Is_Running loop
         select
            -- 接收目標樓層指令
            accept Move_To (Target : Floor_Type) do
               Requests(Target) := True;
               Put_Line ("[Elevator] Floor" & Target'Image & " requested.");
            end Move_To;
         or
            -- 接收停止訊號
            accept Stop do
               Is_Running := False;
            end Stop;
         else
            null;
         end select;

         -- 電梯移動邏輯
         if Requests(Current_Floor) then
            Requests(Current_Floor) := False;
            Put_Line ("[Elevator] Arrived at Floor" & Current_Floor'Image & ", Door Opened.");
         end if;

         if Has_Requests then
            -- 簡單判定移動方向：若沒有方向，找第一個有請求的方向
            if Direction = 0 then
               for F in Floor_Type loop
                  if Requests(F) then
                     if F > Current_Floor then
                        Direction := 1;
                     elsif F < Current_Floor then
                        Direction := -1;
                     end if;
                     exit;
                  end if;
               end loop;
            end if;

            -- 模擬移動耗時 1 秒
            delay 1.0;

            -- 依照方向移動一層樓
            if Direction = 1 and Current_Floor < Floor_Type'Last then
               Current_Floor := Current_Floor + 1;
               Put_Line ("[Elevator] Going up... Now at Floor:" & Current_Floor'Image);
            elsif Direction = -1 and Current_Floor > Floor_Type'First then
               Current_Floor := Current_Floor - 1;
               Put_Line ("[Elevator] Going down... Now at Floor:" & Current_Floor'Image);
            end if;
         else
            -- 完全沒有請求時，電梯靜止
            Direction := 0;
            delay 0.2; -- 避免無謂的 CPU 滿載迴圈
         end if;

      end loop;
      Put_Line ("[Elevator] System closed");
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