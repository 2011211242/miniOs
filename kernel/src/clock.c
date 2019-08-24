extern int disp_pos;
void disp_char(char, char font);

void clock_handle(){
    static int time_count = 0;
    static char ch = 'A';
    disp_pos = 80;

    if (time_count > 5000)
    {
        disp_char(ch, 0x0A);
        time_count = 0;
        ch++;
        if (ch > 'Z') ch = 'A';

    }
    time_count++;
}
