/* Copyright (c) 2018 Gregor Richards
 * Copyright (c) 2017 Mozilla */
/*
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>
#include <stdlib.h>
#include "rnnoise.h"


#define FRAME_SIZE 480

void mix_signal_SNR(short *clean, short *noise, float alpha, float *out)
{
  int i;
  for (i=0; i<FRAME_SIZE; i++)
  {
    out[i] = clean[i] + noise[i]*alpha;
  }
}

int main(int argc, char **argv) {
  int i;
  int first = 1;
  float x[FRAME_SIZE];
  float alpha=0.0;
  FILE *f1, *f2, *fout;
  DenoiseState *st;
  DenoiseState *clean_state;

  clean_state = rnnoise_create(NULL);
  st = rnnoise_create(NULL);
  if (argc!=5) {
    fprintf(stderr, "usage: %s <clean speech> <noise> <alpha> <denoised speech>\n", argv[0]);
    return 1;
  }
  f1 = fopen(argv[1], "rb");  //clean speech
  f2 = fopen(argv[2], "rb");  //noise
  alpha = atof(argv[3]);
  // fprintf(stderr, "alpha string = %s\n", argv[3]);
  fprintf(stderr, "alpha float = %f\n", alpha);
  fout = fopen(argv[4], "wb");  
  while (1) {
    short clean[FRAME_SIZE];
    short noise[FRAME_SIZE];
    short tmp[FRAME_SIZE];
    float ftmp[FRAME_SIZE];
    fread(clean, sizeof(short), FRAME_SIZE, f1);
    fread(noise, sizeof(short), FRAME_SIZE, f2);
    if (feof(f1)||feof(f2)) break;

    // Mixing signal
    mix_signal_SNR(clean, noise, alpha, x);
    for (i=0;i<FRAME_SIZE;i++) ftmp[i] = clean[i];

    rnnoise_process_frame(st, clean_state, x, x, ftmp);

    // Output
    for (i=0;i<FRAME_SIZE;i++) tmp[i] = x[i];
    if (!first) fwrite(tmp, sizeof(short), FRAME_SIZE, fout);
    first = 0;
  }
  rnnoise_destroy(st);
  fclose(f1);
  fclose(f2);
  fclose(fout);
  return 0;
}
