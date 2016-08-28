#include <stdio.h>
#include <math.h>
#include <stdlib.h>

static const int MAX_ITERS = 255;

int main(int argc, char *argv[])
{
  unsigned char *buf;

  unsigned int xsize = 2048;
  unsigned int ysize = 2048;

  if (argc > 1)
  {
    xsize = ysize = atoi(argv[1]);
    if (argc > 2)
    {
      ysize = atoi(argv[2]);
    }
  }

  if (!(buf = malloc(xsize * ysize)))
  {
    fprintf(stderr,"Not enough memory");
    return 1;
  }

  #pragma acc parallel copy(buf[0:xsize*ysize - 1])
  {
    const float xmin = -1.5;
    const float ymin = -1.25;
    const float dx = 2.0 / xsize;
    const float dy = 2.5 / ysize;

    #pragma acc loop worker vector independent
    for (unsigned int i = 0; i < xsize * ysize; i++)
    {
      unsigned int px = i % xsize;
      unsigned int py = i / xsize;

      float x0 = xmin + px*dx;
      float y0 = ymin + py*dy;
      float x = 0.0;
      float y = 0.0;
      unsigned int j = 0;

      for(j = 0; x*x + y*y < 4.0 && j < MAX_ITERS; j++)
      {
        float xtemp = x*x - y*y + x0;
        y = 2*x*y + y0;
        x = xtemp;
      }
      buf[i] = j;
    }
  }

  FILE *out = fopen("test.pgm","w");
  fprintf(out,"P2\n%d %d\n%d\n",xsize,ysize,MAX_ITERS);
  for (int y = 0; y < ysize; y++)
  {
    for (int x = 0; x< xsize; x++)
    {
      fprintf(out,"%d ",buf[y*xsize + x]);
    }
    fprintf(out,"\n");
  }
  free(buf);
  return 0;
}
