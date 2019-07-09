
char helloword[] = "Hello I am kernel\0";
int disp_pos = 180 + 80 * 12;
void disp_char(char c)
{
    asm("mov %0, %%al; \
                mov $0xef, %%ah; \
                mov %1, %%esi; \
                mov %%ax, %%gs:(, %%esi, 2)"
                :
                :"r"(c), "l"(disp_pos)          /*输出部*/
                :"%eax", "%esi"           /*毁坏部*/
           );
}

void disp_str(char * str)
{
    int i = 0;
    while(str[i] != '\0')
    {
        disp_char(str[i]);
        disp_pos += 1;
        i++;
    }
}
