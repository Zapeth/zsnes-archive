// User configuration file

// zspc 0.9.0
#ifndef BLARGG_CONFIG_H
#define BLARGG_CONFIG_H

// Uncomment to disable debugging checks
//#define NDEBUG 1

// Uncomment to enable platform-specific (and possibly non-portable) optimizations
#define BLARGG_NONPORTABLE 1

// Uncomment if you get errors in the bool section of blargg_common.h
//#define BLARGG_COMPILER_HAS_BOOL 1

// Use standard config.h if present
#ifdef HAVE_CONFIG_H
	#include "config.h"
#endif

#endif
