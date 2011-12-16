#ifndef SIMPLE_INCLUDE_SIMPLE_H_
#define SIMPLE_INCLUDE_SIMPLE_H_

#include "types.h"

class Simple {

  float value_;
public:
  Simple(float v) : value_(v) {}

  float value() {
    return value_;
  }

  /** Test typedef resolution in methods.
   */
  MyFloat add(MyFloat v) {
    return value_ + v;
  }

  void setValue(float v) {
    value_ = v;
  }
};

#endif // SIMPLE_INCLUDE_SIMPLE_H_