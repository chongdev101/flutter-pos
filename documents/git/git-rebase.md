### ขั้นตอนที่ปรับปรุงให้ถูกต้อง (The Clean Workflow)

1. **New branch:** สร้าง `feature/getx` แยกออกมาจาก `main` (ถูกต้อง)
2. **Develop:** แก้ไขโค้ดใน `feature/getx` (ถูกต้อง)
3. **Commit:** บันทึกงานไว้ (ถูกต้อง)
4. **Rebase (จุดสำคัญ):** * คุณต้องอยู่ที่ `feature/getx` แล้วสั่ง `git rebase main`
* **ความหมายคือ:** "เอา `main` ล่าสุดมาตั้งเป็นฐาน แล้วเอาสิ่งที่ฉันเพิ่งทำใน `feature/getx` ไปต่อท้ายซะ"

### ขั้นตอน "อัปเดตฐาน" ให้ล่าสุดก่อน Rebase

1. **ไปที่ main เพื่อดึงงานล่าสุดจาก Server:**
```bash
git checkout main
git pull origin main

```


2. **กลับไปที่ branch ของคุณ:**
```bash
git checkout feature/getx

```


3. **สั่ง Rebase บน main ที่เพิ่งอัปเดตมาเมื่อกี้:**
```bash
git rebase main

```


5. **Fast-Forward Merge:** สลับไปที่ `main` แล้วสั่ง `git merge feature/getx` เพื่อเลื่อนตำแหน่ง `main` ขึ้นไปจุดล่าสุด

---

### เปรียบเทียบให้เห็นภาพ (Diagram)

> **ข้อสังเกต:** > ในข้อ 4 ของคุณที่เขียนว่า *Checkout and rebase onto 'feature/getx'* ถ้าคุณใช้โปรแกรมอย่าง **VS Code** หรือ **GitKraken** การคลิกขวาที่ `feature/getx` แล้วเลือก Rebase อาจหมายถึงการเอา Branch อื่นมาวางบนมัน ซึ่งอาจจะสลับฝั่งกันได้
> **จำง่ายๆ:** "เราอยู่ที่ไหน (Branch เรา) เรา Rebase บนฐานของคนอื่น (main)"

---

### แล้วถ้าเกิด Conflict ระหว่าง Rebase ต้องทำอย่างไร?

เมื่อสั่ง Rebase แล้วเจอไฟล์ที่ชนกัน Git จะหยุดรอให้คุณแก้ไข โดยมีคำสั่งที่ต้องใช้ดังนี้:

1. **เปิดไฟล์ที่ Conflict:** แก้ไขโค้ดให้เรียบร้อย
2. **Add ไฟล์:** `git add <ชื่อไฟล์>` (ไม่ต้อง commit)
3. **ไปต่อ:** `git rebase --continue` (เพื่อให้มันทำ commit ถัดไปจนครบ)
* *หรือถ้าจะยกเลิก: `git rebase --abort*`