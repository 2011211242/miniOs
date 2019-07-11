char helloword[] = "Hello I am kernel";
int disp_pos = 180 + 80 * 12;
void disp_char(char c, char font)
{
    //asm("mov %1, %%al; \
    //            mov $0xef, %%ah; \
    //            mov %2, %%esi; \
    //            mov %%ax, %%gs:(, %%esi, 2); \
    //            add $0x01, %%esi; \
    //            mov %%esi, %0;"
    //            :"=r"(disp_pos)
    //            :"r"(c), "r"(disp_pos)      /*输出部*/
    //            :"%eax", "%esi"             /*毁坏部*/
    //       );

    switch (c)
    {
        case '\0':  
            return;
        case '\n':
            disp_pos = (disp_pos / 80 + 1) * 80; 
            break;

        default:
            asm("mov %0, %%al; \
                    mov %1, %%ah; \
                    mov %2, %%esi; \
                    mov %%ax, %%gs:(, %%esi, 2);"
                    :
                    :"r"(c), "r"(font), "r"(disp_pos)      /*输出部*/
                    :"%eax", "%esi"             /*毁坏部*/
               );

            disp_pos ++;
            break;
    }

    if (disp_pos > 25 * 80)
        disp_pos = 25 * 80;
}

void clean_screen()
{
    disp_pos = 0;
    for(int i = 0; i < 20000000; i++) {
        asm("nop");
    } 
    for(int i = 0; i < 25; i++)
    {
        for(int j = 0; j < 80; j++)
        {
            disp_char(' ', 0x0f);
        }

        for(int i = 0; i < 2000000; i++);
    }
    disp_pos = 0;
}

void disp_str(char * str)
{
    int i = 0;
    while(str[i] != '\0')
    {
        disp_char(str[i], 0x8c);
        i++;
    }
}
