package render

import "core:fmt"
import "core:os"
import "core:io"

pipline_init :: proc(vert_file_path, frag_file_path: string, allocator := context.allocator) -> (){
  vert_file, vert_err := os.open(vert_file_path)
  defer os.close(vert_file)

  
  frag_file, frag_err := os.open(vert_file_path)
  defer os.close(frag_file)
  

  os.read_entire_file_from_handle(vert_file)

  
}