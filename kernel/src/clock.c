extern int disp_pos;
void disp_char(char, char font);

#define MAX_TIME_COUNT 8

void clock_handle() {
    static int time_count = MAX_TIME_COUNT;
    static char ch = 'A';
    //disp_pos = 120;

    
    int pos = 120;
    char font = 0x0C; //0x0A;
    if (time_count >= MAX_TIME_COUNT)
    {
        asm ("mov %0, %%al; \
                mov %1, %%ah; \
                mov %2, %%esi; \
                mov %%ax, %%gs:(, %%esi, 2);"
                :
                :"r"(ch), "r"(font), "r"(pos)      //输出部
                :"%eax", "%esi"             //毁坏部
           );


        //disp_char(ch, 0x0A);
        time_count = 0;
        ch++;
        if (ch > 'Z') ch = 'A';

    }
    time_count++;
}
