#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_LINE 1024

/*
Tag	Meaning
.PDNOTE	Special note box (like ⚠️)
.PDQUOTE	Blockquote, story, or tale
.PDCODE	Block of raw source code
.PDIMG	Reference to an inline image
.PDSAY	Quoted pirate speech 🏴‍☠️

 */
int title_done = 0;

void escape_man(const char *in, char *out) {
    while (*in) {
        if (*in == '\\' || *in == '-') // escape backslashes and dashes
            *out++ = '\\';
        *out++ = *in++;
    }
    *out = '\0';
}

void process_lineToMan(const char *line, int *title_done) {
    char out[MAX_LINE * 2];

    if ((line[0] == '-' || line[0] == '+') && line[1] == ' ') {
      escape_man(line + 2, out);
      fprintf(stdout, ".IP \\[bu] 2\n%s\n", out); // .IP = indented paragraph with bullet
    }
    else if (strncmp(line, "#+title:", 8) == 0 && !*title_done) {
      escape_man(line + 8, out);
      fprintf(stdout, ".TH \"%s\" 1 \"July 2025\" \"v1.0\" \"User Manual\"\n", out);
      fprintf(stdout, ".SH NAME\n%s \\- manual entry\n", out);
      *title_done = 1;
    }
    else if (strncmp(line, "#+author:", 9) == 0) {
      escape_man(line + 9, out);
      fprintf(stdout, ".SH AUTHOR\n%s\n", out);
    }
    else if ((strncmp(line, "# ", 2) == 0 && !*title_done)
	     || (strncmp(line, "* ", 2) == 0 && !*title_done)) {
      // First line: .TH and .SH NAME
      const char *title = line + 2;
      escape_man(title, out);
      fprintf(stdout, ".TH \"%s\"\n", out);
      /*fprintf(stdout, ".SH NAME\n%s \\- manual entry\n", out);*/
      *title_done = 1;
    }
    /*else if ((strncmp(line, "## ", 3) == 0) || (strncmp(line, "** ", 3)) ) {
      escape_man(line + 3, out);
      fprintf(stdout, ".SH %s\n", out);
    }*/
    else if (strncmp(line, "**", 2) == 0) {
      escape_man(line + 2, out);
      fprintf(stdout, ".B %s\n", out);
    }
    else if (strlen(line) == 0) {
      /* Blank line */
      fprintf(stdout, ".PP\n");
    }
    else {
      escape_man(line, out);
      fprintf(stdout, "%s\n", out);
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

    char line[MAX_LINE];
    int title_done = 0;

    while (fgets(line, MAX_LINE, in)) {
        line[strcspn(line, "\n")] = 0;
        process_line(line, &title_done);
    }

    if (in != stdin)
        fclose(in);

    return 0;
}
