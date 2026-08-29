# Elevator Simulator (`elevator_sim`)

這是一個使用 **Ada** 模擬電梯系統的專案，練習 Ada 的 Concurrent Programming（Task 機制）與強型別特性。

## 功能

- 自訂 1 到 10 樓的強型別樓層範圍 (`Floor_Type`)
- 使用 Ada Task 實作非同步電梯控制與狀態發送
- 模擬電梯升降、每樓層停靠延遲與開關門狀態
- 支援平滑停止與系統關閉指令

## 環境需求

- GNAT Ada 編譯器

## 如何編譯與執行

1. 使用 GNAT 編譯：
   ```bash
   gnatmake main.adb

## 版本更新資訊
v0.03，修正Control Menu在輸入數字完後才出現的bug
v0.02，新增用戶可選擇樓層，選擇0則退出
