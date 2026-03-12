# 🎃Cusom interrupt 09h to your attention!
## Paint frame of regs

---

## 🧸How to use

### (If u use dosbox, I can help)
Clone asm file -> open dosbox -> ptintf in console of Dosbox: // ***tasm /la "name_of_file.asm"*** //-> // ***tlink /t "name_of_file.obj"*** //-> ***"name_of_file.com"***.

If you want try ready-some-work programm, clone file ***<resident/trio_buf_.asm>***.

---

If u want to use some parts of programm, go to ***<resident/components>***. Then you can find three parts:

### <change_intrr.asm>
--Its func just cath int09h. So everything you press-> scan code-> ASCIII-> center of video memory;

### <new_met.asm>
--(some of back ups) nothing of idea triple buffering, but work with esc from Volkov (/ my trick)) /);

### <pai_reg.asm>
--func for paint registers (read descr in file);

### <trio_buf_.asm>
--its realization from Aliexpress;

---

(about she10_of10_without_but.asm)
## 🌌What did

Press 6 //-> A frame with registers is drawn.

Press 9 //-> Hide frame.

<img width="1056" height="848" alt="Снимок экрана 2026-03-05 в 17 09 07" src="https://github.com/user-attachments/assets/7b8281fe-ccdc-4871-9281-87e3bfcac76d" />

---

## ✨Bugs
If you hover the mouse over the window => unforeseen circumstances.
