package odus

import "render"
import "core:fmt"
import rt "core:runtime"

Vector3 :: struct {
  x: f32,
  y: f32,
  z: f32,
}


main :: proc() {
  using render
  
  window_init(800, 800)
  defer window_deinit()

  for !window_should_close() {

  }


  

}