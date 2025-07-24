#include <stdio.h>
#include <string.h>

#define MAX_LINE 1024

/*
.TH	Title Header
.SH	Section Header
.B	Bold
.I	Italic
.TP	Tagged paragraph (indented list)
.PP	Paragraph
.RS/.RE	Relative indent
.nf/.fi	Disable/Enable filling (for code blocks)
 */


void
escape_ps(const char *in, char *out)
{
  while (*in) {
    if (*in == '(' || *in == ')' || *in == '\\')
      *out++ = '\\';
    *out++ = *in++;
  }
  *out = '\0';
}


void
process_line_toPS(const char *line)
{
  if (strncmp(line, ".Th ", 4) == 0) {
    // Title line
    fprintf(stdout, "/Helvetica-Bold findfont 18 scalefont setfont\n");
    char escaped[MAX_LINE * 2];
    escape_ps(line + 4, escaped); // Skip ".Th "
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



int
main(int argc, char *argv[])
{
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
    
  /*while (fgets(line, MAX_LINE, in)) {
    line[strcspn(line, "\n")] = 0;
    escape_ps(line, escaped);
    fprintf(stdout, "(%s) show\n0 -14 rmoveto\n", escaped);
    }*/
  while (fgets(line, MAX_LINE, in)) {
    line[strcspn(line, "\n")] = 0;  // Strip newline
    process_line_toPS(line);       // Delegate to your custom logic
  }
  
  fprintf(stdout, "showpage\n");
  
  if (in != stdin)
    fclose(in);
  return 0;
}
