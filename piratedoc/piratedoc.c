#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024

typedef enum {
  INPUT_MAN,
  INPUT_MDOC,
  INPUT_ASCII,
  INPUT_MARKDOWN,
  OUTPUT_PS,
  OUTPUT_PDF,
  OUTPUT_PIRATEDOC,
  OUTPUT_HTML
} Mode;

void process_line_toPS(const char *line);
void process_lineToMan(const char *line, int *title_done);

/*void escape_ps(const char *in, char *out) {
    while (*in) {
        if (*in == '(' || *in == ')' || *in == '\\')
            *out++ = '\\';
        *out++ = *in++;
    }
    *out = '\0';
    }*/

void
process_line(const char *line, int mode)
{
  /*if (strncmp(line, "# ", 2) == 0) {
    // Title line
    fprintf(stdout, "/Helvetica-Bold findfont 18 scalefont setfont\n");
    char escaped[MAX_LINE * 2];
    escape_ps(line + 2, escaped);
    fprintf(stdout, "(%s) show\n0 -24 rmoveto\n", escaped);
    fprintf(stdout, "/Courier findfont 12 scalefont setfont\n"); // Reset
  } */
  if(mode == OUTPUT_PS) {
    process_line_toPS(line);
  }
  else if(mode == OUTPUT_PIRATEDOC) {
    process_line_ToMan
  }
  
}


int main(int argc, char *argv[]) {
    FILE *in = stdin;
    if (argc > 1) {
        in = fopen(argv[1], "r");
        if (!in) {
            perror("fopen");
            return 1;
        }
    }

    char line[MAX_LINE], escaped[MAX_LINE * 2];

    fprintf(stdout, "%%pirateps - a smaller groff! ");
    fprintf(stdout, "%%!PS-Adobe-3.0\n");
    fprintf(stdout, "/Courier findfont 12 scalefont setfont\n");
    fprintf(stdout, "72 720 moveto\n");

    while (fgets(line, MAX_LINE, in)) {
        line[strcspn(line, "\n")] = 0;
        escape_ps(line, escaped);
        fprintf(stdout, "(%s) show\n0 -14 rmoveto\n", escaped);
    }

    fprintf(stdout, "showpage\n");

    if (in != stdin)
        fclose(in);
    return 0;
}
