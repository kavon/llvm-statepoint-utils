#ifndef GSYM_H
#define GSYM_H

#ifdef __linux__
  #define GSYM(X) X
#endif

#ifdef __APPLE__
  #define GSYM(X) _X
#endif

#endif // GSYM_H
