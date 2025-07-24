#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024
int title_done = 0;
/*
Tag     Meaning
.PDNOTE Special note box (like ⚠)
.PDQUOTE        Blockquote, story, or tale
.PDCODE Block of raw source code
.PDIMG  Reference to an inline image
.PDSAY  Quoted pirate speech 🏴☠

 */


void escape_ps(const char *in, char *out) {
  while (*in) {
    if (*in == '(' || *in == ')' || *in == '\\')
      *out++ = '\\';
    *out++ = *in++;
  }
  *out = '\0';
}


void process_line_toPS(const char *line) {
    if (strncmp(line, "# ", 2) == 0) {
        // Title line
        fprintf(stdout, "/Helvetica-Bold findfont 18 scalefont setfont\n");
        char escaped[MAX_LINE * 2];
        escape_ps(line + 2, escaped);
        fprintf(stdout, "(%s) show\n0 -24 rmoveto\n", escaped);
        fprintf(stdout, "/Courier findfont 12 scalefont setfont\n"); // Reset
    } else if (strncmp(line, "**", 2) == 0) {
        // Bold text block
        fprintf(stdout, "/Courier-Bold findfont 12 scalefont setfont\n");
        char escaped[MAX_LINE * 2];
        escape_ps(line + 2, escaped);
        fprintf(stdout, "(%s) show\n0 -14 rmoveto\n", escaped);
        fprintf(stdout, "/Courier findfont 12 scalefont setfont\n");
    } else {
        // Default
        char escaped[MAX_LINE * 2];
        escape_ps(line, escaped);
        fprintf(stdout, "(%s) show\n0 -14 rmoveto\n", escaped);
    }
}


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

