# 🎃Cusom interrapt 09h to your attention!
## Paint frame of regs

---

## 🧸How to use

### (If u use dosbox, I can help)
Clon asm file -> open dosbox -> ptintf in console of Db: // ***tasm /la "name_of_file.asm"*** //-> // ***tlink /t "name_of_file.obj"*** //-> ***"name_of_file.com"***

If you want try ready-some-work programm, clon file ***<resident/trio_buf_.asm>***

---

If u want to use some parts of programm, go to ***<resident/components>***. Then you can find three parts:

### <change_intrr.asm>
--Its func just cath int09h. So everything you press-> scan code-> ASCIII-> centr of video memory

### <new_met.asm>
--(some of back ups) nothing of idea trio bufferization, but work with esc from volkov (/ my trick)) /)

### <pai_reg.asm>
--func for paint registr (read descr of func in file)

---

(about trio_buf_.asm)
## 🌌What did

Press 6 //-> A frame with registers is drawn

Press 9 //-> Hide ramka

<img width="1056" height="848" alt="Снимок экрана 2026-03-05 в 17 00 01" src="https://github.com/user-attachments/assets/8d9a5e45-71ca-4240-8a0e-cdc8739750cd" />

---

## ✨Bugs
Triple buffering is not full now (fast version use only one symbol to compare) => if you draw anyting on frame (not full) => its not save

If you hover the mouse over the window => unforeseen circumstances
