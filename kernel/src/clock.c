extern int disp_pos;
void disp_char(char, char font);

#define MAX_TIME_COUNT 25

void clock_handle(){
    static int time_count = MAX_TIME_COUNT;
    static char ch = 'A';
    disp_pos = 120;

    
    if (time_count >= MAX_TIME_COUNT)
    {
        disp_char(ch, 0x0A);
        time_count = 0;
        ch++;
        if (ch > 'Z') ch = 'A';

    }
    time_count++;
}
