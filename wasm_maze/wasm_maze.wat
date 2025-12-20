;; Kenny Fully made this example. May GOD bless you.
;; Please understand that the maze editor feature is coming soon!
(module
  ;; imports
  (import "sound" "playDataSound" (func $play_data_sound (param i32)))
  ;; exports
  (memory (export "memory") 3) ;; 196608 bytes
  ;; mutable variables
  (global $countup            (mut i32) (i32.const 0 ))
  (global $maze_cleared       (mut i32) (i32.const 0 ))
  (global $maze_index         (mut i32) (i32.const 0 ))
  (global $maze_init          (mut i32) (i32.const 0 ))
  (global $maze_selected      (mut i32) (i32.const 0 ))
  (global $player_mode        (mut i32) (i32.const 0 ))
  (global $player_lucky       (mut i32) (i32.const 0 ))
  (global $player_size        (mut i32) (i32.const 16))
  (global $player_x           (mut i32) (i32.const 16))
  (global $player_y           (mut i32) (i32.const 16))
  (global $scene_index        (mut i32) (i32.const 0 )) ;; current scene 0 = Title; 1 = Maze Select; 2 = Game
  (global $timer_30           (mut i32) (i32.const 0 )) ;; 30 frame counter
  (global $timer_60           (mut i32) (i32.const 0 )) ;; 60 frame counter
  (global $timer_cooldown_15  (mut i32) (i32.const 0 )) ;; used for limiting repeating sounds
  (global $title_image_loaded (mut i32) (i32.const 0 )) ;; check to see if title image loaded

  ;; functions
   
  (func $check_for_lucky (result i32 i32 i32)
    global.get $player_lucky
    i32.const 0x00000001
    i32.eq
    if (result i32 i32 i32)
      i32.const 0xFF000080
      i32.const 0xFF0000FF
      i32.const 0xFF00FFFF
    else
      i32.const 0xFF000000
      i32.const 0xFFF04F65
      i32.const 0xFFFFFFFF
    end
  )

  (func $check_item_on_map (param $i i32) (param $item_index i32) (result i32)
    i32.const 400
    global.get $maze_index
    i32.mul
    i32.const 154688 ;; memory_address_pointer_for_mazes
    i32.add
    local.get $i
    i32.add
    i32.load8_u
    local.get $item_index
    i32.eq
  )

  (func $collision_check_key (param $color_index i32) (param $i i32)
    local.get $i
    call $player_to_object_collision
    if
      local.get $i
      call $player_to_object_collision
      if          
        i32.const 0x0000020B ;; sound tone
        call $play_data_sound
        i32.const 400
        global.get $maze_index
        i32.mul
        i32.const 154688 ;; memory_address_pointer_for_mazes
        i32.add
        local.get $i
        i32.add        
        i32.const 0x09 ;; indicates key picked up
        local.get $color_index
        i32.add
        i32.store8

        ;; update key status
        i32.const 158348 ;; memory_address_pointer_for_key_obtain_status
        local.get $color_index
        i32.add
        i32.const 1
        i32.store8
      end
    end
  )

  (func $collision_check_lock (param $color_index i32) (param $i i32)
    local.get $i
    call $player_to_object_collision
    if
      i32.const 158348
      local.get $color_index
      i32.add
      i32.load8_u
      i32.const 0x00000001
      i32.eq
      if          
        i32.const 0x0000015D ;; sound tone
        call $play_data_sound
        i32.const 400
        global.get $maze_index
        i32.mul
        i32.const 154688 ;; memory_address_pointer_for_mazes
        i32.add
        local.get $i
        i32.add        
        i32.const 0x0C ;; indicates unlocked
        i32.store8
        i32.const 158348
        local.get $color_index
        i32.add
        i32.const 0x00000000
        i32.store8
      else
        call $pushback_player
      end
    end
  )
  
  (func $collision_checks (local $i i32)
    loop $loop
      ;; check if a sweet_rock collides
      local.get $i
      i32.const 1
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          call $pushback_player
        end
      end
      ;; check if a wasm_block collides
      local.get $i
      i32.const 2
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          i32.const 0x00000106 ;; sound tone
          call $play_data_sound
          ;; set maze_cleared
          i32.const 1
          global.set $maze_cleared
          ;; add trophy to the maze button if maze level is less than 8
          global.get $maze_index
          i32.const 8
          i32.lt_s
          if
            i32.const 158288 ;; address for trophies
            global.get $maze_index
            i32.add
            i32.const 1
            i32.store8
          end
        end
      end
      ;; check if a key_red collides
      local.get $i
      i32.const 3
      call $check_item_on_map
      if
        i32.const 0
        local.get $i
        call $collision_check_key
      end
      ;; check if a key_green collides
      local.get $i
      i32.const 4
      call $check_item_on_map
      if
        i32.const 1
        local.get $i
        call $collision_check_key
      end
      ;; check if a key_blue collides
      local.get $i
      i32.const 5
      call $check_item_on_map
      if
        i32.const 2
        local.get $i
        call $collision_check_key
      end
      ;; check if a lock_red collides
      local.get $i
      i32.const 6
      call $check_item_on_map
      if
        i32.const 0
        local.get $i
        call $collision_check_lock
      end
      ;; check if a lock_green collides
      local.get $i
      i32.const 7
      call $check_item_on_map
      if
        i32.const 1
        local.get $i
        call $collision_check_lock
      end
      ;; check if a lock_blue collides
      local.get $i
      i32.const 8
      call $check_item_on_map
      if
        i32.const 2
        local.get $i
        call $collision_check_lock
      end
      ;; increment i
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 400 ;; max amount of items on a map
      i32.lt_s
      br_if $loop
    end
  )
  
  (func $player_to_object_collision (param $i i32) (result i32)
    global.get $player_x
    i32.const 3
    i32.add
    global.get $player_y
    i32.const 6
    i32.add
    i32.const 10 ;; player_hitbox_size
    local.get $i
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul       ;; object_x
    local.get $i
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul     ;; object_y
    i32.const 16 ;; object_size
    call $square_collision
    i32.const 1 ;; check for true
    i32.eq
  )

  (func $pushback_player
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
      i32.const 15
      global.set $timer_cooldown_15
      i32.const 0x00000106 ;; sound tone
      call $play_data_sound
    end
    global.get $player_mode
    i32.const 1
    i32.eq
    if
      global.get $player_y
      i32.const 1
      i32.add
      global.set $player_y
    else
      global.get $player_mode
      i32.const 2
      i32.eq
      if
        global.get $player_y
        i32.const 1
        i32.sub
        global.set $player_y
      else
        global.get $player_mode
        i32.const 3
        i32.eq
        if
          global.get $player_x
          i32.const 1
          i32.add
          global.set $player_x
        else
          global.get $player_mode
          i32.const 4
          i32.eq
          if
            global.get $player_x
            i32.const 1
            i32.sub
            global.set $player_x
          end
        end
      end
    end
  )

  ;; render a sprite based on index colors
  (func $render_color_indexed_sprite
    (param $dx i32)
    (param $dy i32)
    (param $dw i32)
    (param $dh i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    (param $color_04 i32)
    (param $color_05 i32)
    (param $data_address i32)
    (local $i i32)
    (local $j i32)
    (local $color_index i32)
    ;; for some reason init local variables to avoid rare bugs
    i32.const 0
    local.set $i
    i32.const 0
    local.set $j
    i32.const 0
    local.set $color_index
    loop $loop_y
      i32.const 0
      local.set $j
      loop $loop_x
        ;; Check bounds - y first
        local.get $dy
        local.get $i
        i32.add
        i32.const 0
        i32.ge_s
        if
          local.get $dy
          local.get $i
          i32.add
          i32.const 160 ;; gamebox_height
          i32.lt_s
          if
            ;; Check x bounds
            local.get $dx
            local.get $j
            i32.add
            i32.const 0
            i32.ge_s
            if
              local.get $dx
              local.get $j
              i32.add
              i32.const 160 ;; gamebox_width
              i32.lt_s
              if
                ;; Get sprite data: i * dw + j
                local.get $i
                local.get $dw
                i32.mul
                local.get $j
                i32.add
                local.get $data_address
                i32.add
                i32.load8_u
                i32.const 0
                i32.ne
                if
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 1
                  i32.eq
                  if
                    local.get $color_01
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 2
                  i32.eq
                  if
                    local.get $color_02
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 3
                  i32.eq
                  if
                    local.get $color_03
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 4
                  i32.eq
                  if
                    local.get $color_04
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 5
                  i32.eq
                  if
                    local.get $color_05
                    local.set $color_index
                  end
                  ;; Calculate pixel buffer offset: (dy+i) * width + (dx+j)
                  local.get $dy
                  local.get $i
                  i32.add
                  i32.const 160 ;; gamebox_width
                  i32.mul
                  local.get $dx
                  local.get $j
                  i32.add
                  i32.add
                  i32.const 4
                  i32.mul
                  local.get $color_index
                  i32.store
                end
              end
            end
          end
        end
        local.get $j
        i32.const 1
        i32.add
        local.set $j
        local.get $j
        local.get $dw
        i32.lt_s
        br_if $loop_x
      end
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      local.get $dh
      i32.lt_s
      br_if $loop_y
    end
  )

  (func $render_key
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_dx
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_x
    i32.add
    global.get $player_x
    i32.sub
    local.get $i         ;; key_dy
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_y
    i32.add
    global.get $player_y
    i32.sub
    i32.const 16         ;; key_dw
    i32.const 16         ;; key_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133632     ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_lock
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_red_dx
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_x
    i32.add
    global.get $player_x
    i32.sub
    local.get $i         ;; key_red_dy
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_y
    i32.add
    global.get $player_y
    i32.sub
    i32.const 16         ;; key_red_dw
    i32.const 16         ;; key_red_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    i32.const 0x00000000  ;; color_04
    i32.const 0x00000000  ;; color_05
    i32.const 133888      ;; data_address
    call $render_color_indexed_sprite
  )

  ;; render map
  (func $render_map (local $i i32)
    loop $loop
      ;; check for sweet_rock
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 1
      i32.eq
      if
        local.get $i
        i32.const 20
        i32.rem_s
        i32.const 16
        i32.mul
        i32.const 72          ;; cam_x
        i32.add
        global.get $player_x
        i32.sub               ;; dx
        local.get $i
        f32.convert_i32_s
        i32.const 20
        f32.convert_i32_s
        f32.div
        f32.floor
        i32.trunc_f32_s
        i32.const 16
        i32.mul
        i32.const 72             ;; cam_y
        i32.add
        global.get $player_y
        i32.sub                  ;; dy
        i32.const 0x00000010     ;; dw
        i32.const 0x00000010     ;; dh
        i32.const 0xFF000000     ;; color_01
        i32.const 0xFFF5F5FF        
        i32.const 0xFFF7F7FF
        global.get $timer_30
        i32.const 9
        i32.lt_s
        select
        i32.const 0xFFFFFFFF
        global.get $timer_30
        i32.const 19
        i32.lt_s
        select                  ;; color_02
        i32.const 158341
        i32.load8_u
        i32.const 0xFF000000
        i32.or                  ;; color_03
        i32.const 0xFFF04F65    ;; color_04
        i32.const 0xFF9CE1FF    ;; color_05
        i32.const 130560        ;; data_address
        call $render_color_indexed_sprite
      end
      ;; check for wasm_block
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 2
      i32.eq
      if
        local.get $i         ;; wasm_block_dx
        i32.const 20
        i32.rem_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_x
        i32.add
        global.get $player_x
        i32.sub
        local.get $i         ;; wasm_block_dy
        f32.convert_i32_s
        i32.const 20
        f32.convert_i32_s
        f32.div
        f32.floor
        i32.trunc_f32_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_y
        i32.add
        global.get $player_y
        i32.sub
        i32.const 16         ;; wasm_block_dw
        i32.const 16         ;; wasm_block_dh
        i32.const 0xFFFF0000
        i32.const 0xFFF04F65
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        i32.const 0x00000000 ;; color_04
        i32.const 0x00000000 ;; color_05
        i32.const 133376     ;; data_address
        call $render_color_indexed_sprite
      end
      ;; check for key_red
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 3
      i32.eq
      if
        local.get $i
        i32.const 0xFF0000FF
        i32.const 0xFF000080
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for key_green
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 4
      i32.eq
      if
        local.get $i
        i32.const 0xFF00FF00
        i32.const 0xFF008000
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for key_blue
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 5
      i32.eq
      if
        local.get $i
        i32.const 0xFFFF0000
        i32.const 0xFF800000
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for lock_red
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 6
      i32.eq
      if
        local.get $i
        i32.const 0xFF0000FF ;; color_01
        i32.const 0xFF00FFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_lock
      end
      ;; check for lock_green
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 7
      i32.eq
      if
        local.get $i
        i32.const 0xFF008000 ;; color_01
        i32.const 0xFF00FFFF   ;; color_02
        i32.const 0x00000000   ;; color_03
        call $render_lock
      end
      ;; check for lock_blue
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 154688   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 8
      i32.eq
      if
        local.get $i
        i32.const 0xFFFF0000 ;; color_01
        i32.const 0xFF00FFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_lock
      end
      ;; increment i
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 400 ;; max amount of possible items on a map
      i32.lt_s
      br_if $loop
    end
  )

  (func $rgb_fill_screen (param $color i32) (local $i i32)
    i32.const 0
    local.set $i
    loop $loop
      ;; Calculate memory offset: i * 4
      local.get $i
      i32.const 2
      i32.shl             ;; i << 2 is equivalent to i * 4 (much faster)
      local.get $color
      i32.store           ;; Store the entire 32-bit word (4 bytes) at once
      local.get $i
      i32.const 0x00000001
      i32.add
      local.set $i
      local.get $i
      i32.const 25600
      i32.lt_s
      br_if $loop
    end
  )  
  
  (func $square_collision
    (param $x1 i32) (param $y1 i32) (param $size1 i32) 
    (param $x2 i32) (param $y2 i32) (param $size2 i32) 
    (result i32)
    (local $x1_end i32) (local $y1_end i32) 
    (local $x2_end i32) (local $y2_end i32)
    
    ;; calculate the right/bottom edges of both squares
    local.get $x1
    local.get $size1
    i32.add
    local.set $x1_end
    
    local.get $y1
    local.get $size1
    i32.add
    local.set $y1_end
    
    local.get $x2
    local.get $size2
    i32.add
    local.set $x2_end
    
    local.get $y2
    local.get $size2
    i32.add
    local.set $y2_end
    
    ;; check collision using AABB
    ;; if (x1 < x2_end && x1_end > x2 && y1 < y2_end && y1_end > y2)
    local.get $x1
    local.get $x2_end
    i32.lt_s
    if
      local.get $x1_end
      local.get $x2
      i32.gt_s
      if
        local.get $y1
        local.get $y2_end
        i32.lt_s
        if
          local.get $y1_end
          local.get $y2
          i32.gt_s
          if
            i32.const 1
            return
          end
        end
      end
    end
    i32.const 0
  )

  ;; scenes
  
  (func $scene_title
    global.get $title_image_loaded
    i32.const 1
    i32.ne
    if
      i32.const 1
      global.set $title_image_loaded
      i32.const 0
      i32.const 0
      i32.const 160
      i32.const 160
      i32.const 0xFFFFFFFF
      i32.const 0xFFF04F65
      i32.const 0xFF0000FF
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 102400
      call $render_color_indexed_sprite
    end
    global.get $countup
    i32.const 179
    i32.lt_s
    if
      global.get $countup
      i32.const 1
      i32.add
      global.set $countup
    else
      i32.const 0
      global.set $countup
      i32.const 1
      global.set $scene_index
    end    
  )

  (func $scene_maze_select (local $i i32)

      global.get $maze_selected
      i32.const 0
      i32.eq
      if
        i32.const 0xFFF08197
        call $rgb_fill_screen
        ;; render maze select buttons
        loop $loop
          ;; button_x
          i32.const 16
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          i32.const 32
          i32.const 0xFFF04F65
          i32.const 0xFF00FFFF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 148672          
          call $render_color_indexed_sprite
          ;; number_x
          i32.const 24
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; number_y
          i32.const 24
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; number_size
          i32.const 16
          i32.const 16
          i32.const 0xFF0000FF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 149696
          local.get $i
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 158288
          local.get $i
          i32.add
          i32.load8_u
          i32.const 1
          i32.eq
          if
            i32.const 39
            local.get $i
            i32.const 3
            i32.rem_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 39
            local.get $i
            f32.convert_i32_s
            i32.const 3
            f32.convert_i32_s
            f32.div
            f32.floor
            i32.trunc_f32_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 8
            i32.const 8
            i32.const 0xFFF04F65
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 152000 
            call $render_color_indexed_sprite
          end
          ;; check col
          ;; pointer
          i32.const 158344
          i32.load8_u
          i32.const 158345
          i32.load8_u
          i32.const 1
          ;; button_x
          i32.const 16
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          call $square_collision
          i32.const 1
          i32.eq
          if
            local.get $i
            i32.const 8
            i32.eq
            if
              i32.const 3 ;; scene_maze_maker
              global.set $scene_index
            else
              ;; normal modes
              i32.const 1
              global.set $maze_init
          
              local.get $i
              global.set $maze_index ;; set the maze index
              i32.const 1
              global.set $maze_selected

              ;; Check to see if player is lucky
              global.get $timer_60
              i32.const 56 ;; player will have a 5% chance to be lucky
              i32.ge_s
              if
                i32.const 1
                global.set $player_lucky
              else
                i32.const 0
                global.set $player_lucky
              end

              ;; TODO: set player x and y depending on maze
              local.get $i
              i32.const 0
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 1
              i32.eq
              if
                i32.const 288
                global.set $player_x
                i32.const 288
                global.set $player_y
              end

              local.get $i
              i32.const 2
              i32.eq
              if
                i32.const 152
                global.set $player_x
                i32.const 152 
                global.set $player_y
              end

              local.get $i
              i32.const 3
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 4
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 5
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 272 
                global.set $player_y
              end

              local.get $i
              i32.const 6
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 7
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end
            end
          end
          ;; increment by 1
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          local.get $i
          i32.const 9 ;; 9 buttons are needed
          i32.lt_s
          br_if $loop
        end
      else
        ;; for when maze selected
        global.get $countup
        i32.const 59
	    i32.lt_s
        if
          i32.const 0xFF3B3B3B
          call $rgb_fill_screen
          ;; button_x
          i32.const 16
          global.get $maze_index
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          global.get $maze_index
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          i32.const 32
          i32.const 0xFFF04F65
          i32.const 0xFF00FFFF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 148672
          call $render_color_indexed_sprite          
          ;; number
          i32.const 24
          global.get $maze_index
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          i32.const 24
          global.get $maze_index
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          i32.const 16
          i32.const 16
          i32.const 0xFF0000FF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 149696
          global.get $maze_index
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 158288
          global.get $maze_index
          i32.add
          i32.load8_u
          i32.const 1
          i32.eq
          if
            i32.const 39
            global.get $maze_index
            i32.const 3
            i32.rem_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 39
            global.get $maze_index
            f32.convert_i32_s
            i32.const 3
            f32.convert_i32_s
            f32.div
            f32.floor
            i32.trunc_f32_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 8
            i32.const 8
            i32.const 0xFFF04F65
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 152000             
            call $render_color_indexed_sprite
          end
          global.get $countup
          i32.const 1
          i32.add
          global.set $countup
        else
          i32.const 0
          global.set $maze_selected
          i32.const 2 ;; go to game scene
          global.set $scene_index
	      i32.const 0
	      global.set $countup
	      i32.const 2
	      global.set $scene_index
        end
      end
  )
 
  (func $scene_game
    (local $mask_copy i32)
    (local $value_copy i32)
    ;; check to see if maze cleared
    global.get $maze_cleared
    i32.const 1
    i32.eq
    if
      i32.const 0xFFFFFFFF
      call $rgb_fill_screen
      ;; if maze cleared show the you win modal
      i32.const 0x00000028 ;; dx
      i32.const 0x00000040 ;; dy
      i32.const 0x00000050 ;; dw
      i32.const 0x00000020 ;; dh
      i32.const 158340     ;; timer_memory_address
      i32.load8_u          ;; value
      i32.const 0xFF000000 ;; base_color
      i32.or               ;; color_01
      i32.const 0xFF000000 ;; color_02
      i32.const 0xFF000000 ;; color_03
      i32.const 0x00000000 ;; color_04
      i32.const 0x00000000 ;; color_05
      i32.const 152128     ;; data_address
      call $render_color_indexed_sprite      
      ;; increment $countup if less than 179
      global.get $countup
      i32.const 179
      i32.lt_s
      if
        global.get $countup
        i32.const 1
        i32.add
        global.set $countup
      else
        i32.const 0
        global.set $maze_cleared
        i32.const 0
        global.set $countup
        i32.const 1
        global.set $scene_index
      end
    else
      i32.const 0xFFDFFFDF
      call $rgb_fill_screen
      call $render_map
      ;; render player
      global.get $timer_30
      i32.const 14
      i32.lt_s
      if
        i32.const 72 ;; cam_x
        i32.const 72 ;; cam_y
        i32.const 16
        i32.const 16
        call $check_for_lucky
        i32.const 0xFF0000FF
        i32.const 0x00000000
        i32.const 130816
        global.get $player_mode
        i32.const 512
        i32.mul
        i32.add
        call $render_color_indexed_sprite
      else
        i32.const 72 ;; cam_x
        i32.const 72 ;; cam_y
        i32.const 16
        i32.const 16
        call $check_for_lucky
        i32.const 0xFF0000FF
        i32.const 0x00000000
        i32.const 131072 
        global.get $player_mode
        i32.const 512
        i32.mul
        i32.add
        call $render_color_indexed_sprite
      end

      ;; key_icon_red
      i32.const 158348
      i32.load8_u
      i32.const 0x00000001
      i32.eq
      if
        i32.const 0x00000088 ;; dx
        i32.const 0x00000098 ;; dy
        i32.const 0x00000008 ;; dw
        i32.const 0x00000008 ;; dh
        i32.const 0xFF0000FF ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        i32.const 0x00000000 ;; color_04
        i32.const 0x00000000 ;; color_05
        i32.const 134336     ;; memory_address
        call $render_color_indexed_sprite
      end

      ;; key_icon_green
      i32.const 158349
      i32.load8_u
      i32.const 0x00000001
      i32.eq
      if
        i32.const 0x00000090 ;; dx
        i32.const 0x00000098 ;; dy
        i32.const 0x00000008 ;; dw
        i32.const 0x00000008 ;; dh
        i32.const 0xFF008000 ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        i32.const 0x00000000 ;; color_04
        i32.const 0x00000000 ;; color_05
        i32.const 134336     ;; memory_address
        call $render_color_indexed_sprite
      end

      ;; key_icon_blue
      i32.const 158350
      i32.load8_u
      i32.const 0x00000001
      i32.eq
      if
        i32.const 0x00000098 ;; dx
        i32.const 0x00000098 ;; dy
        i32.const 0x00000008 ;; dw
        i32.const 0x00000008 ;; dh
        i32.const 0xFFFF0000 ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        i32.const 0x00000000 ;; color_04
        i32.const 0x00000000 ;; color_05
        i32.const 134336     ;; memory_address
        call $render_color_indexed_sprite
      end

      ;; update player position
      i32.const 158344
      i32.load8_u
      i32.const 255
      i32.ne
      if
        i32.const 158345
        i32.load8_u
        i32.const 80 ;; half of the screen 
        i32.sub
        ;; i32_abs_inline_function        
        ;; --- INLINED i32_abs (Bitwise Trick) ---
        local.tee $value_copy  ;; Stack: [..., -10, -10]. Saves a copy to a local $value_copy
        i32.const 31           ;; Stack: [..., -10, 31]
        i32.shr_s              ;; Stack: [..., mask] (mask = -1 for -10)
        local.tee $mask_copy   ;; Stack: [..., mask, mask]. Saves mask to a local $mask_copy
        local.get $value_copy  ;; Stack: [..., mask, mask, -10]
        i32.xor                ;; Stack: [..., mask, (value XOR mask)]
        local.get $mask_copy   ;; Stack: [..., (value XOR mask), mask]
        i32.sub                ;; Stack: [..., ABS(value)] ((value XOR mask) - mask)

        i32.const 158344
        i32.load8_u
        i32.const 80 ;; half of the screen 
        i32.sub
        ;; --- INLINED i32_abs (Bitwise Trick) ---
        local.tee $value_copy  ;; Stack: [..., -10, -10]. Saves a copy to a local $value_copy
        i32.const 31           ;; Stack: [..., -10, 31]
        i32.shr_s              ;; Stack: [..., mask] (mask = -1 for -10)
        local.tee $mask_copy   ;; Stack: [..., mask, mask]. Saves mask to a local $mask_copy
        local.get $value_copy  ;; Stack: [..., mask, mask, -10]
        i32.xor                ;; Stack: [..., mask, (value XOR mask)]
        local.get $mask_copy   ;; Stack: [..., (value XOR mask), mask]
        i32.sub                ;; Stack: [..., ABS(value)] ((value XOR mask) - mask)
        i32.gt_s
        if
          i32.const 158345
          i32.load8_u
          i32.const 72 ;; cam_y
          i32.lt_s
          if
            global.get $player_y
            i32.const 1
            i32.sub
            global.set $player_y
            ;; up
            i32.const 1
            global.set $player_mode
          else
            global.get $player_y
            i32.const 1
            i32.add
            global.set $player_y
            ;; down
            i32.const 2
            global.set $player_mode
          end
        else
          i32.const 158344
          i32.load8_u 
          i32.const 72 ;; cam_x
          i32.lt_s
          if
            global.get $player_x
            i32.const 1
            i32.sub
            global.set $player_x
            ;; left
            i32.const 3
            global.set $player_mode
          else
            global.get $player_x
            i32.const 1
            i32.add
            global.set $player_x
            ;; right
            i32.const 4
            global.set $player_mode
          end
        end
      else
        i32.const 0
        global.set $player_mode ;; idle
      end
      ;; check for solids etc
        call $collision_checks
      end

      ;; just a fade in
      global.get $maze_init
      i32.const 1
      i32.eq
      if
        i32.const 0xFF3B3B3B
        call $rgb_fill_screen

        global.get $countup
        i32.const 59
        i32.gt_s
        if
          i32.const 0
          global.set $maze_init
        else
          global.get $countup
          i32.const 1
          i32.add
          global.set $countup
        end
      end
  )

  (func $scene_maze_maker (local $i i32) (local $j i32)
    i32.const 0xFFFFFFFF
    call $rgb_fill_screen

    ;; maze_maker_button_close_16x16
    i32.const 0x00000000 ;; dx
    i32.const 0x00000000 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 134464     ;; memory_address
    call $render_color_indexed_sprite

    ;; map_background
    i32.const 0
    local.set $i
    loop $loop_i
      i32.const 0
      local.set $j
      loop $loop_j
        i32.const 16
        local.get $i
        i32.mul
        i32.const 24
        i32.add              ;; dx
        i32.const 16
        local.get $j
        i32.mul
        i32.const 24
        i32.add              ;; dy
        i32.const 0x00000010 ;; dw
        i32.const 0x00000010 ;; dh
        i32.const 0xFFF0F0FF ;; color_01
        i32.const 0xFFF0FFF0 ;; color_02
        i32.const 0xFF000000 ;; color_03
        i32.const 0xFF000000 ;; color_04
        i32.const 0xFF000000 ;; color_05
        i32.const 134976     ;; memory_address
        call $render_color_indexed_sprite
        local.get $j
        i32.const 1
        i32.add
        local.set $j
        local.get $j
        i32.const 5
        i32.lt_s
        br_if $loop_j
      end
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 5
      i32.lt_s
      br_if $loop_i
    end

    ;; arrow_up
    i32.const 0x00000038 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129536     ;; memory_address
    call $render_color_indexed_sprite
    ;; arrow_down
    i32.const 0x00000038 ;; dx
    i32.const 0x00000068 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129792     ;; memory_address
    call $render_color_indexed_sprite
    ;; arrow_left
    i32.const 0x00000008 ;; dx
    i32.const 0x00000038 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 130048     ;; memory_address
    call $render_color_indexed_sprite
    ;; arrow_right
    i32.const 0x00000068 ;; dx
    i32.const 0x00000038 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 130304     ;; memory_address
    call $render_color_indexed_sprite
    ;; todo: make a representation of erase

    ;; sweet_rock
    i32.const 0x00000088 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFF0000FF ;; color_03
    i32.const 0xFFF04F65 ;; color_04
    i32.const 0xFF9CE1FF ;; color_05
    i32.const 130560     ;; memory_address
    call $render_color_indexed_sprite

    ;; player_idle
    i32.const 0x00000078 ;; dx
    i32.const 0x00000018 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF04F65 ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0xFF0000FF ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 130816     ;; memory_address
    call $render_color_indexed_sprite

    ;; wasm_block
    i32.const 0x00000088 ;; dx
    i32.const 0x00000018 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFF04F65 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133376     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_red
    i32.const 0x00000078 ;; dx
    i32.const 0x00000050 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133632     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_red
    i32.const 0x00000088 ;; dx
    i32.const 0x00000050 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133888     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_green
    i32.const 0x00000078 ;; dx
    i32.const 0x00000060 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133632     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_green
    i32.const 0x00000088 ;; dx
    i32.const 0x00000060 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133888     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_blue
    i32.const 0x00000078 ;; dx
    i32.const 0x00000070 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133632     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_blue
    i32.const 0x00000088 ;; dx
    i32.const 0x00000070 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133888     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_play_button
    i32.const 0x00000008 ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 135232     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_load_button
    i32.const 0x0000003C ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 135872     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_share_button
    i32.const 0x00000070 ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 136512     ;; memory_address
    call $render_color_indexed_sprite

    ;; todo: make a better way to show maze_maker_selected_indicator
    i32.const 0x00000088 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF
    i32.const 0xFF000080
    global.get $timer_60
    i32.const 0x0000001D
    i32.lt_s
    select               ;; color_01
    i32.const 0x00000000 ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 134720     ;; memory_address
    call $render_color_indexed_sprite

    ;; todo: make a better way to exit maze edit mode
    i32.const 158344
    i32.load8_u ;; pointer_x
    i32.const 0x00000010
    i32.lt_s
    if
      i32.const 158345
      i32.load8_u ;; pointer_y
      i32.const 0x00000010
      i32.lt_s
      if
        i32.const 0x00000001 ;; go back to scene_maze_select
        global.set $scene_index
      end
    end
  )

  ;; game loop
  (func (export "game_loop")  
    (local $i i32)

    global.get $scene_index
	i32.const 0
	i32.eq
	if
      call $scene_title
	end

    global.get $scene_index
	i32.const 1
	i32.eq
	if
     call $scene_maze_select
    end

    global.get $scene_index
	i32.const 2
	i32.eq
	if
      call $scene_game
	end

    global.get $scene_index
	i32.const 3
	i32.eq
	if
      call $scene_maze_maker
	end

    ;; render_pointer
    i32.const 158344     ;; dx_data_address
    i32.load8_u          ;; dx_value
    i32.const 0x00000008 ;; offset -8
    i32.sub              ;; visually centering dx
    i32.const 158345     ;; dy_data_address
    i32.load8_u          ;; dy_value
    i32.const 0x00000008 ;; offset -8
    i32.sub              ;; visually centering dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 128000     ;; memory_address_f1
    i32.const 128256     ;; memory_address_f2
    global.get $timer_30
    i32.const 14
    i32.lt_s
    select
    call $render_color_indexed_sprite

    ;; todo work on timers
    global.get $timer_30
    i32.const 29
    i32.lt_s
    if
      global.get $timer_30
      i32.const 1
      i32.add
      global.set $timer_30
    else
      i32.const 0
      global.set $timer_30
    end

    global.get $timer_60
    i32.const 59
    i32.lt_s
    if
      global.get $timer_60
      i32.const 1
      i32.add
      global.set $timer_60
    else
      i32.const 0
      global.set $timer_60
    end

    ;; TIMERS
    i32.const 158340 ;; timer_01
    i32.const 158340
    i32.load8_u
    i32.const 8
    i32.add
    i32.store8
    
    i32.const 158341 ;; timer_02
    i32.const 158341
    i32.load8_u
    i32.const 4
    i32.add
    i32.store8

    i32.const 158342 ;; timer_03
    i32.const 158342
    i32.load8_u
    i32.const 2
    i32.add
    i32.store8

    i32.const 158343 ;; timer_04
    i32.const 158343
    i32.load8_u
    i32.const 1
    i32.add
    i32.store8

    global.get $timer_cooldown_15
    i32.const 0
    i32.gt_s
    if
      global.get $timer_cooldown_15
      i32.const 1
      i32.sub
      global.set $timer_cooldown_15
    end
  )

  (data (i32.const 0x00019000)
    ;; 102400 | title_160x160 = 25600 bytes      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
     
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"

    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"

    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"     
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01" "\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01" "\01\01\02\02\02\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01" "\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\01" "\02\02\02\02\01\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01" "\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\02\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01" "\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01" "\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01" "\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\01\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\01\01\01\02\02" "\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\02\02\02\02\02\02\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\02" "\02\02\01\01\01\02\02\02\01\01\01\01\01\01\01\01" "\01\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\01\01\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\02\01\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\01\01\01\01\02\01\01\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\02\01\02\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\03\03" "\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    ;; 128000 | pointer_16x16_f1 = 256 bytes
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\01\02\02\01\00\00\00\00\00\00\00\00\01\02\02\01"
    "\01\02\01\01\00\00\00\00\00\00\00\00\01\01\02\01"
    "\01\01\01\00\00\00\00\00\00\00\00\00\00\01\01\01"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\01\01\01\00\00\00\00\00\00\00\00\00\00\01\01\01"
    "\01\02\01\01\00\00\00\00\00\00\00\00\01\01\02\01"
    "\01\02\02\01\00\00\00\00\00\00\00\00\01\02\02\01"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    ;; 128256 | pointer_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\01\02\02\01\00\00\00\00\00\00\01\02\02\01\00"
    "\00\01\02\01\01\00\00\00\00\00\00\01\01\02\01\00"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\00\01\02\01\01\00\00\00\00\00\00\01\01\02\01\00"
    "\00\01\02\02\01\00\00\00\00\00\00\01\02\02\01\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 128512 | heart_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\01\00\00\01\01\01\01\00\00\00"
    "\00\00\01\02\02\02\02\01\01\02\02\02\02\01\00\00"
    "\00\01\02\02\03\02\02\01\02\02\03\02\02\02\01\00"
    "\00\01\02\03\02\02\02\01\02\03\02\02\02\02\01\00"
    "\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00"
    "\00\00\01\02\02\02\02\02\02\02\02\02\02\01\00\00"
    "\00\00\00\01\02\02\02\02\02\02\02\02\01\00\00\00"
    "\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 128768 | heart_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\00\01\01\01\01\00\00\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\02\01\02\02\03\02\02\02\01\00\00"
    "\00\00\00\01\02\03\01\02\03\02\02\02\02\01\00\00"
    "\00\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00"
    "\00\00\00\00\01\02\02\02\02\02\02\02\01\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129024 | heart_16x16_f3 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\02\02\03\02\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\03\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129280 | heart_16x16_f4 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\00\01\01\00\00\00\00\00"
    "\00\00\00\01\02\02\02\02\01\02\02\01\00\00\00\00"
    "\00\00\01\02\02\03\02\02\02\01\02\02\01\00\00\00"
    "\00\00\01\02\03\02\02\02\02\01\02\02\01\00\00\00"
    "\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\02\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129536 | arrow_up_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129792 | arrow_down_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 130048 | arrow_left_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 130304 | arrow_right_16x16 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 130560 | sweet_rock_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\01\01\02\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\02\02\02\03\03\02\02\02\01\00\00\00"
    "\00\00\01\02\02\02\03\02\03\03\02\02\02\01\00\00"
    "\00\00\01\02\02\04\03\03\03\03\04\02\02\01\00\00"
    "\00\01\02\02\02\04\03\03\03\03\04\02\02\02\01\00"
    "\00\01\02\02\02\02\04\03\03\04\02\02\02\02\01\00"
    "\00\01\02\04\02\02\02\02\02\02\02\02\02\04\01\00"
    "\00\01\04\05\02\04\02\02\02\02\02\04\04\05\01\00"
    "\00\00\01\05\04\05\02\04\02\04\04\05\05\01\00\00"
    "\00\00\01\05\05\05\04\05\04\05\05\05\05\01\00\00"
    "\00\00\00\01\05\05\05\05\05\05\05\05\01\00\00\00"
    "\00\00\00\00\01\01\05\05\05\05\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 130816 | player_idle_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\00\00\00\00\00\00"
    "\00\01\02\03\03\02\02\01\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\02\02\02\02\01\01\01\02\02\02\01\00\00"
    "\00\00\01\02\02\02\01\02\02\02\01\02\01\00\00\00"
    "\00\00\00\01\01\01\02\03\02\03\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\03\03\03\01\00\00\00\00"
    "\00\00\00\00\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\02\01\01\00\00\00"
    "\00\00\00\00\01\03\01\02\02\02\01\03\01\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\03\01\03\03\01\00\00\00\00"
    ;; 131072 | player_idle_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\03\03\02\01\00"
    "\00\01\02\03\03\02\02\01\01\01\02\02\02\02\01\00"
    "\00\01\02\03\03\02\02\01\02\03\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\03\03\03\01\01\00\00\00"
    "\00\00\01\02\02\02\01\01\03\01\03\01\00\00\00\00"
    "\00\00\00\01\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\02\03\04\03\02\02\02\01\00\00"
    "\00\00\00\00\01\01\02\02\02\02\02\01\01\00\00\00"
    "\00\00\00\00\00\01\03\01\02\01\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\01\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\01\00\01\03\01\00\00\00\00"
    ;; 131328 | player_up_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\02\02\02\01\00\00"
    "\00\00\00\01\01\01\00\00\01\02\03\03\02\02\01\00"
    "\00\00\01\03\02\02\01\00\01\02\03\03\02\02\01\00"
    "\00\00\01\02\02\02\01\01\01\02\02\02\02\02\01\00"
    "\00\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00"
    "\00\00\00\00\01\02\02\01\02\02\01\01\01\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\01\00\00\00\00\00"
    "\00\00\00\01\01\02\01\01\01\02\01\01\00\00\00\00"
    "\00\00\01\02\02\02\01\02\01\02\02\02\01\00\00\00"
    "\00\00\00\01\01\02\02\01\02\01\01\01\00\00\00\00"
    "\00\00\00\01\03\01\02\02\01\01\00\00\00\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\03\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\01\01\01\00\00\00\00\00\00"
    ;; 131584 | player_up_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00\00"
    "\00\01\03\02\02\01\00\00\00\01\02\02\02\01\00\00"
    "\00\01\02\02\02\02\01\01\01\02\03\03\02\02\01\00"
    "\00\00\01\02\02\02\02\02\02\01\03\03\02\02\01\00"
    "\00\00\00\01\01\02\02\01\02\02\02\02\02\02\01\00"
    "\00\00\00\00\01\02\01\02\01\02\01\02\02\01\00\00"
    "\00\00\00\01\01\02\01\01\01\02\01\01\01\00\00\00"
    "\00\00\01\02\02\02\01\02\01\02\02\02\01\00\00\00"
    "\00\00\00\01\01\02\02\01\02\02\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\02\02\01\03\01\00\00\00\00"
    "\00\00\00\00\01\03\03\01\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\03\03\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\03\01\00\00\00\00\00\00"
    ;; 131840 | player_down_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\00\00\00\00\00\00"
    "\00\01\02\03\03\02\02\01\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\02\02\02\02\01\01\01\02\02\02\01\00\00"
    "\00\00\01\02\02\02\01\02\02\02\01\02\01\00\00\00"
    "\00\00\00\01\01\01\02\03\02\03\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\03\03\03\01\00\00\00\00"
    "\00\00\00\00\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\01\01\01\00\00\00"
    "\00\00\00\00\01\03\01\02\02\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\01\03\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\03\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\03\01\01\01\00\00\00\00\00"
    ;; 132096 | player_down_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\03\03\02\01\00"
    "\00\01\02\03\03\02\02\01\01\01\02\02\02\02\01\00"
    "\00\01\02\03\03\02\02\01\02\02\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\02\03\02\01\01\00\00\00"
    "\00\00\01\02\02\02\01\03\03\03\03\01\00\00\00\00"
    "\00\00\00\01\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\02\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\02\02\01\03\01\00\00\00"
    "\00\00\00\00\00\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\03\01\00\00\00\00\00"
    ;; 132352 | player_left_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\02\02\02\01\00\00\00\00\00\00\00"
    "\00\00\00\01\02\03\03\02\01\01\01\01\00\00\00\00"
    "\00\00\00\01\02\01\01\01\01\02\03\03\01\00\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\03\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\01\03\03\03\02\02\01\01\00\00\00\00\00"
    "\00\00\00\01\03\01\03\02\02\02\01\00\00\00\00\00"
    "\00\00\01\03\03\01\03\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\04\03\02\01\01\02\02\02\01\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\01\01\00\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\01\01\02\02\02\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\03\03\01\00\00\00\00\00\00"
    ;; 132608 | player_left_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\01\01\01\00\00\00"
    "\00\00\00\00\01\02\02\02\01\01\02\03\03\01\00\00"
    "\00\00\00\01\02\01\01\01\01\02\02\02\02\01\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\03\02\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\03\03\03\02\02\02\01\00\00\00\00\00"
    "\00\00\00\01\03\01\03\02\02\02\01\00\00\00\00\00"
    "\00\00\01\03\03\01\03\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\04\03\02\02\01\01\02\02\01\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\01\00\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\01\00\00\00\00"
    "\00\00\00\00\01\01\02\02\01\01\02\02\01\00\00\00"
    "\00\00\00\01\03\03\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\01\01\01\00\01\03\01\00\00\00\00\00"
    ;; 132864 | player_right_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\00\00\00\01\01\00\00\00\00"
    "\00\00\00\01\02\02\02\01\00\01\03\02\01\00\00\00"
    "\00\00\01\02\03\03\02\02\01\01\01\02\01\00\00\00"
    "\00\00\01\02\03\03\02\02\01\02\02\01\00\00\00\00"
    "\00\00\01\02\02\02\02\02\01\02\03\02\01\00\00\00"
    "\00\00\00\01\02\02\02\01\02\03\03\03\01\00\00\00"
    "\00\00\00\00\01\01\01\02\02\03\01\03\01\00\00\00"
    "\00\00\00\00\01\02\02\02\02\03\01\03\03\01\00\00"
    "\00\00\00\01\02\02\02\01\01\02\03\04\01\00\00\00"
    "\00\00\00\00\01\01\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\01\02\02\02\01\01\02\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\03\01\00\00\00\00\00\00"
    ;; 133120 | player_right_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\03\03\02\02\01\01\01\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\02\02\02\01\01\00\00\00"
    "\00\00\01\02\02\02\01\02\02\02\03\02\01\00\00\00"
    "\00\00\00\01\01\01\02\02\02\03\03\03\01\00\00\00"
    "\00\00\00\00\00\01\02\02\02\03\01\03\01\00\00\00"
    "\00\00\00\00\01\01\02\02\02\03\01\03\03\01\00\00"
    "\00\00\00\01\02\02\01\01\02\02\03\04\01\00\00\00"
    "\00\00\00\00\01\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\01\02\02\01\01\02\02\01\01\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\03\03\01\00\00\00"
    "\00\00\00\00\00\01\03\01\00\01\01\01\00\00\00\00" 
    ;; 133376 | wasm_block_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\01\02\01\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\02\01\02\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\02\01\02\01\00"
    "\00\01\01\01\01\02\02\02\02\02\01\02\02\02\01\00"
    "\00\01\01\01\01\01\02\01\02\01\01\02\01\02\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 133632 | key_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\02\01\02\02\01\02\01\01\00\00\00"
    "\00\00\00\01\01\02\02\01\01\02\02\01\01\00\00\00"
    "\00\00\00\01\01\01\01\02\02\01\01\01\01\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" 
    ;; 133888 | lock_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\01\02\02\01\01\01\01\02\02\01\00\00\00"
    "\00\00\00\01\02\01\00\00\00\00\01\02\01\00\00\00"
    "\00\00\00\01\02\01\00\00\00\00\01\02\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00"
    "\00\01\01\01\01\02\02\01\01\02\02\01\01\01\01\00"
    "\00\01\02\02\02\02\01\01\01\01\02\02\02\02\01\00"
    "\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00"
    "\00\01\02\02\02\02\01\01\01\01\02\02\02\02\01\00"
    "\00\01\01\02\02\02\02\01\01\02\02\02\02\01\01\00"
    "\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 134144 | maze_maker_icon_sweet_rock_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\00\00"
    "\00\01\02\03\03\02\01\00"
    "\00\01\04\03\03\04\01\00"
    "\00\01\05\04\04\05\01\00"
    "\00\01\05\05\05\05\01\00"
    "\00\00\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 134208 | maze_maker_icon_player_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\02\01\02\01\01\00"
    "\00\02\03\02\03\02\01\00"
    "\00\02\03\02\03\02\01\00"
    "\00\01\02\04\02\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00"
    ;; 134272 | maze_maker_icon_wasm_block_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\01\01\00\00\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\02\02\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00"
    ;; 134336 | maze_maker_icon_key_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\01\02\01\00\00\00"
    "\00\00\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 134400 | maze_maker_icon_lock_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\01\00\00\01\00\00"
    "\00\00\01\01\01\01\00\00"
    "\00\01\02\02\02\02\01\00"
    "\00\01\02\01\01\02\01\00"
    "\00\00\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 134464 | maze_maker_button_close_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00"
    "\00\01\01\01\02\02\02\01\01\02\02\02\01\01\01\00"
    "\00\01\01\01\01\02\02\02\02\02\02\01\01\01\01\00"
    "\00\01\01\01\01\01\02\02\02\02\01\01\01\01\01\00"
    "\00\01\01\01\01\01\02\02\02\02\01\01\01\01\01\00"
    "\00\01\01\01\01\02\02\02\02\02\02\01\01\01\01\00"
    "\00\01\01\01\02\02\02\01\01\02\02\02\01\01\01\00"
    "\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 134720 | maze_maker_selected_indicator_16x16 | 256 bytes
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\00\00\00\00\00\00\00\00\00\00\01\01\00"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01"
    "\00\01\01\00\00\00\00\00\00\00\00\00\00\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    ;; 134976 | maze_maker_map_background_16x16 = 256 bytes
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    "\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    ;; 135232 | maze_maker_play_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\01\01\01\01\01\02\02\02\02\01\01\02" "\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01" "\01\02\01\01\02\02\02\01"
    "\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\02\01\01\01\02\02\01"
    "\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\02\01\01\01\02\02\01"
    "\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01" "\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01" "\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01" "\01\01\01\01\01\02\02\01"
    "\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\01" "\01\01\01\01\02\02\02\01"
    "\01\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01" "\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02\02" "\01\01\01\02\02\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01" "\01\01\01\02\02\01\01\01\02\01\01\01\02\02\02\02" "\01\01\01\02\02\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01" "\01\01\01\02\02\01\01\01\02\01\01\01\02\02\02\02" "\01\01\01\02\02\02\02\01"
    "\01\02\02\02\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\01\01\02\01\01\02\02\02\02\02" "\02\01\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    ;; 135872 | maze_maker_load_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"     
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\01\01\01\01\01\02\02\02\01\01" "\01\01\01\01\02\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01" "\01\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\01\01\01\01\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02" "\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02" "\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02" "\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02" "\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\01\01\02\02\02\01\01\02\02" "\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02" "\02\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01" "\01\02\02\01\01\02\02\01"
    "\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01" "\01\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\02\01\01\01\01\01\02\02\02\02\01\01\01" "\01\01\02\02\02\02\01\01\02\01\01\02\02\02\01\01" "\01\01\01\01\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    ;; 136512 | maze_maker_share_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"      
    "\01\02\02\02\01\01\01\02\02\02\02\01\02\01\02\02" "\02\02\01\01\01\01\02\02\02\02\01\01\01\02\02\02" "\02\01\01\01\02\02\02\01"      
    "\01\02\02\01\01\01\01\01\02\02\01\01\02\01\01\02" "\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\01\01\02\01\01\02\02\01\01\02\01\01\02" "\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02" "\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02" "\01\01\01\02\02\02\02\01"      
    "\01\02\02\01\01\01\01\02\02\02\01\01\01\01\01\02" "\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\02\01\01\01\01\02\02\01\01\01\01\01\02" "\02\01\01\01\01\01\01\02\02\01\01\01\01\02\02\02" "\01\01\01\01\01\02\02\01"
    "\01\02\02\02\02\02\01\01\02\02\01\01\01\01\01\02" "\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02" "\01\01\01\02\02\02\02\01"
    "\01\02\02\01\01\02\01\01\02\02\01\01\02\01\01\02" "\02\01\01\02\02\01\01\02\02\01\01\01\01\01\02\02" "\01\01\01\01\01\02\02\01"      
    "\01\02\02\01\01\01\01\01\02\02\01\01\02\01\01\02" "\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02" "\01\01\01\01\01\02\02\01"
    "\01\02\02\02\01\01\01\02\02\02\02\01\02\01\02\02" "\02\02\01\02\02\01\02\02\02\01\01\02\01\01\02\02" "\02\01\01\01\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\01"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\00"
    ;; 137152 | maze_maker_modal_01 = 3840 bytes
    "\00\00\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\00\00\00\01\03\03\03\03\03\03\01\01\01\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\00\01\03\03\03\03\03\03\03\03\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\03\03\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\03\03\03\03\03\03\01\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\01\01\01\01\01\01\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\02\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\02\02\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\02\02\02\04\04\04\04\02\02\04\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\02\02\02\02\02\04\04\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\04\02\02\04\04\04\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\00\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\00\00\00\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\00\00"
    ;; 140992 | maze_maker_modal_02 = 3840 bytes
    "\00\00\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\00\00\00\01\03\03\03\03\03\03\01\01\01\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\00\01\03\03\03\03\03\03\03\03\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\03\03\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\03\03\03\03\03\03\01\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\01\01\01\01\01\01\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\02\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\02\02\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\02\02\02\04\04\04\04\02\02\04\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\02\02\02\02\02\04\04\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\04\02\02\04\04\04\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\00\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\00\00\00\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\00\00"
    ;; 144832 | maze_maker_modal_03 = 3840 bytes
    "\00\00\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\00\00\00\01\03\03\03\03\03\03\01\01\01\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\00\01\03\03\03\03\03\03\03\03\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\01\01\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\01\03\03\01\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\03\03\03\03\03\03\03\03\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\03\03\03\03\03\03\01\01\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\01\01\01\01\01\01\01\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\01\02\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\01\02\02\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\02\02\02\04\04\04\04\02\02\04\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\02\02\02\02\04\04\02\02\02\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\04\04\04\02\02\04\04\02\02\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\04\04\02\02\02\02\02\02\02\04\04\04\02\02\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\02\02\02\02\04\02\02\02\02\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\04\04\04\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\02\02\02\04\04\04\04\02\02\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\02\02\02\02\04\04\04\02\04\04\04\02\04\04\04\02\02\04\02\02\04\04\04\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\04\02\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\02\04\04\00\04\04\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\04\04\00\00\00\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\04\00\00"
    ;; 148672 | maze_select_button_32x32 = 1024 bytes
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\01\02\01\02\02\02\01" "\02\02\01\01\01\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\02\02\01\02\01\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\01" "\01\02\02\01\02\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\01\02\02\02\01\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\01\01\01\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"

    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    ;; 149696 | maze_select_button_number_label_16x16x9 = 2304 bytes
    ;; 1
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 2
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 3
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 4
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 5
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 6
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\00\01\01\01\01\01\01\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\00\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 7
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 8
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\00\00\01\01\01\01\01\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\00\00\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; ?
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 152000 | maze_select_button_trophy_icon_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\01\00\00\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 152064 | maze_select_button_lucky_icon_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\00\01\00\00\00"
    "\00\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\00\00"
    "\00\00\01\01\01\00\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 152128 | you_win_overlay_80x32 = 2560 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" 
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00" "\01\01\01\00\00\00\00\00\00\00\01\01\01\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00" "\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\01" "\01\01\01\01\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\01" "\01\01\01\01\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\01\01" "\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\00\01\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\01\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\00\00\01\01\01" "\01\00\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\01\01\01" "\01\00\01\01\01\01\00\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00"

    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\01\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00\01" "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; This portion of data is for maze maps
    ;; 00 = nothing
    ;; 01 = sweet rock
    ;; 02 = wasm block
    ;; 03 = key (red)
    ;; 04 = key (green)
    ;; 05 = key (blue)
    ;; 06 = lock (red)
    ;; 07 = lock (green)
    ;; 08 = lock (blue)
    ;; 09 = picked key (red)
    ;; 0A = picked key (green)
    ;; 0B = picked key (blue)
    ;; 0C = unlocked lock (red)
    ;; 0D = unlocked lock (green)
    ;; 0E = unlocked lock (blue)
  
    ;; 154688 | maze_000_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\06\00\01\02\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\00\00\00\01\00\01\00\01"

    "\01\05\00\00\00\00\00\00\00\08" "\00\00\00\00\00\01\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\01\01\01\01\01"
    "\01\00\00\00\00\00\00\00\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\00\00\01\01\00\00\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\01\00\01\01\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\01\00\01\00\07" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\01\00\01\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\01\00\01\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\03\00\00\00\01\00\00\00\01" "\00\00\00\00\00\00\00\00\04\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 155088 | maze_001_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\02\00\00\01\05\00\00\00\01" "\00\01\00\00\00\01\00\04\00\01"
    "\01\01\01\07\01\01\01\00\01\01" "\00\01\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\01\00\01\00\01\01\06\01\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\01\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\01\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\01\00\01\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\01\00\01\00\01\00\00\00\01"

    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\00\01\00\00\00\01"
    "\01\00\00\01\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\03\00\01\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\08\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\01\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\01\01\01\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\01\00\01\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\01\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 155488 | maze_002_20x20 = 400 bytes    
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\04\01\00\00\00\00\00\00\01" "\01\00\00\00\00\00\00\07\03\01"
    "\01\08\01\00\00\00\00\01\00\01" "\01\00\00\00\00\00\00\01\01\01"
    "\01\00\00\00\00\00\00\01\00\01" "\01\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\01\00\01" "\01\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\01\00\01" "\01\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\01\00\01" "\01\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\01\00\01" "\01\01\01\01\01\01\01\01\00\01"
    "\01\00\00\00\00\00\00\01\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01"

    "\01\01\01\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\01\00\00\00\00\00\00\01"
    "\01\00\01\01\01\01\01\01\01\01" "\01\00\01\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\01\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\01\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\01\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\01\00\01\00\00\00\00\00\00\01"
    "\01\01\01\00\00\00\00\00\00\01" "\01\00\01\00\00\00\00\01\00\01"
    "\01\02\06\00\00\00\00\00\00\01" "\01\00\00\00\00\00\00\01\05\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 155888 | maze_003_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\00\00\01\00\00\00\00\00" "\00\03\01\00\00\00\00\00\00\01"
    "\01\00\01\00\01\00\01\00\00\01" "\01\01\01\01\01\01\01\00\01\01"
    "\01\00\01\00\01\00\01\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\01\00\01\00\01\01\01\01" "\01\01\01\00\01\00\01\01\00\01"
    "\01\00\01\00\01\00\01\00\00\00" "\00\00\00\00\01\00\00\01\00\01"
    "\01\00\01\00\01\00\01\00\00\00" "\00\00\00\00\01\01\00\01\00\01"
    "\01\08\01\00\01\00\01\00\00\00" "\00\00\00\00\01\00\00\01\00\01"
    "\01\02\01\00\01\00\01\00\00\00" "\00\00\00\00\01\00\01\01\00\01"
    "\01\01\01\00\01\00\01\00\00\00" "\00\00\01\01\01\00\01\01\01\01"

    "\01\00\00\00\00\00\01\00\00\00" "\00\00\01\00\00\00\01\05\00\01"
    "\01\00\01\01\01\01\01\01\01\01" "\01\01\01\00\01\01\01\01\07\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\01\00\01\00\01\00\00\01"
    "\01\00\01\00\00\00\00\00\00\00" "\01\00\01\00\01\00\01\00\01\01"
    "\01\01\01\01\00\01\01\01\01\00" "\01\00\01\00\01\00\00\00\00\01"
    "\01\00\01\00\00\00\01\04\01\00" "\00\01\01\00\01\00\01\01\00\01"
    "\01\00\00\00\00\00\01\00\01\01" "\00\00\01\00\01\00\01\00\00\01"
    "\01\00\01\01\00\01\01\00\06\01" "\01\00\01\00\01\00\01\01\01\01"
    "\01\00\01\00\00\00\01\01\00\00" "\00\00\01\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 156288 | maze_004_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\01\00\00\00\01\00\00\00" "\00\01\00\00\00\00\00\00\00\01"
    "\01\00\01\00\01\00\01\00\01\01" "\00\00\00\01\00\01\01\01\00\01"
    "\01\00\00\00\01\00\01\00\01\00" "\00\01\00\00\00\01\00\00\00\01"
    "\01\01\01\01\01\00\01\00\01\01" "\01\00\01\01\00\01\00\01\01\01"
    "\01\05\00\01\00\00\01\00\01\00" "\00\00\00\00\00\01\00\00\00\01"
    "\01\00\00\01\00\01\01\00\01\00" "\01\01\01\01\01\01\01\01\00\01"
    "\01\01\00\06\00\00\00\00\01\00" "\00\00\01\00\00\00\00\01\00\01"
    "\01\02\01\01\01\00\01\01\01\00" "\01\00\00\00\01\00\01\01\00\01"
    "\01\08\01\00\00\00\01\00\01\01" "\01\01\01\01\01\01\01\01\00\01"

    "\01\00\01\00\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\00\01"
    "\01\00\01\00\00\00\00\01\01\01" "\01\01\01\00\01\01\01\01\00\01"
    "\01\00\01\01\01\01\00\01\00\01" "\00\00\00\00\01\01\00\01\00\01"
    "\01\00\00\01\00\00\00\01\00\01" "\00\01\01\01\00\00\00\01\00\01"
    "\01\00\00\01\00\01\01\01\00\01" "\00\00\00\01\00\01\00\01\04\01"
    "\01\00\01\01\00\00\00\00\00\01" "\01\01\00\01\00\01\00\01\01\01"
    "\01\00\00\01\01\01\01\01\00\01" "\03\01\00\00\00\01\00\00\00\01"
    "\01\00\00\01\00\00\00\01\00\01" "\00\01\01\01\01\01\07\01\01\01"
    "\01\01\00\00\00\01\00\00\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 156688 | maze_005_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\01\00\01\01\00\01\01\03\01" "\01\00\01\01\00\01\01\00\01\01"
    "\01\00\00\00\00\00\00\00\00\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\00\01\01\00\01\01\01\01" "\01\00\01\01\00\01\01\01\01\01"
    "\01\01\08\01\01\01\01\01\00\01" "\01\00\01\01\01\01\01\00\01\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\00\01\01\00\01\01\00\01" "\01\00\01\01\00\01\01\00\01\01"
    "\01\01\00\01\01\00\01\01\00\01" "\01\00\01\01\00\01\01\00\01\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\01\00\00\00\00\00\00\01"
    "\01\01\00\01\01\00\01\01\00\01" "\01\00\01\01\00\01\01\00\01\01"

    "\01\00\00\00\00\00\00\00\00\01" "\01\00\01\01\00\01\01\00\01\01"
    "\01\00\01\01\01\01\01\01\00\00" "\01\00\00\00\00\00\00\00\00\01"
    "\01\00\01\01\00\00\00\01\01\01" "\01\00\01\01\00\01\01\06\01\01"
    "\01\00\01\01\00\02\00\01\00\01" "\01\01\01\01\00\01\01\00\01\01"
    "\01\00\01\01\00\00\00\01\00\00" "\00\00\00\00\00\01\00\00\00\01"
    "\01\00\01\01\01\07\01\01\00\01" "\01\01\01\01\00\01\01\00\01\01"
    "\01\00\01\01\01\00\01\01\00\01" "\01\00\01\01\00\01\01\00\01\01"
    "\01\00\01\00\00\00\00\00\00\00" "\01\00\00\00\00\01\00\00\00\01"
    "\01\01\01\01\01\00\01\01\05\01" "\01\00\01\01\00\01\01\04\01\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 157088 | maze_006_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\00\00\00\00\00\01\00\00" "\00\01\00\00\01\04\00\00\00\01"
    "\01\01\01\01\00\01\01\01\00\01" "\00\00\00\01\01\01\01\01\00\01"
    "\01\00\00\00\00\01\00\00\00\01" "\00\01\00\00\01\00\00\01\00\01"
    "\01\00\01\01\01\01\00\01\00\01" "\00\01\01\00\01\00\01\01\00\01"
    "\01\00\00\00\00\01\00\01\01\01" "\00\01\00\00\00\00\01\00\00\01"
    "\01\01\01\01\00\00\00\01\03\01" "\00\01\00\01\00\00\01\00\01\01"
    "\01\00\05\01\07\01\01\01\00\01" "\00\00\01\01\01\00\00\00\00\01"
    "\01\00\01\00\00\00\00\00\00\01" "\01\00\00\01\00\01\01\01\01\01"
    "\01\00\01\00\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\00\01"

    "\01\00\01\01\00\00\01\00\00\00" "\01\01\01\01\01\01\01\01\06\01"
    "\01\00\00\01\00\00\00\00\01\00" "\01\00\00\00\00\00\00\01\00\01"
    "\01\00\00\01\00\00\00\01\01\00" "\01\00\01\01\08\01\01\01\00\01"
    "\01\01\00\01\00\01\00\00\01\00" "\01\00\01\01\02\01\00\00\00\01"
    "\01\00\00\01\01\01\01\00\01\00" "\01\00\01\01\01\01\00\01\00\01"
    "\01\00\01\01\00\01\00\00\01\00" "\01\00\00\00\00\01\00\01\00\01"
    "\01\00\01\00\00\00\01\00\01\00" "\01\00\01\00\00\01\00\01\00\01"
    "\01\00\01\00\01\00\01\00\01\00" "\01\00\01\01\01\01\01\01\00\01"
    "\01\00\00\00\01\00\00\00\01\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 157488 | maze_007_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\00\00\00\01\03\01\00\00" "\00\00\00\00\00\01\00\06\00\01"
    "\01\00\01\01\00\01\00\01\00\01" "\01\01\01\01\00\01\00\01\00\01"
    "\01\00\01\00\00\07\00\01\00\00" "\00\00\00\01\00\00\00\01\00\01"
    "\01\00\01\00\01\01\01\01\01\01" "\01\01\00\01\01\01\01\01\00\01"
    "\01\00\01\00\00\00\00\00\00\00" "\00\01\00\00\02\01\05\01\00\01"
    "\01\00\01\01\01\01\01\01\01\01" "\00\01\01\01\01\01\00\01\00\01"
    "\01\00\00\00\00\01\00\00\00\01" "\00\00\00\01\00\00\00\01\00\01"
    "\01\01\01\01\00\01\00\01\01\01" "\01\01\00\01\00\01\01\01\00\01"
    "\01\00\00\00\00\01\00\00\00\00" "\00\00\00\01\00\00\00\00\00\01"

    "\01\00\01\01\01\01\01\01\00\01" "\01\01\01\01\01\01\01\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\00\00\00\00\00\00\00\01\00\01"
    "\01\01\01\01\01\01\01\01\00\01" "\00\01\01\01\01\01\00\01\00\01"
    "\01\00\00\00\00\01\00\00\00\00" "\00\00\00\01\00\00\00\01\00\01"
    "\01\01\01\01\00\01\00\01\01\01" "\01\01\00\01\00\01\01\01\00\01"
    "\01\00\00\00\00\01\00\00\00\01" "\00\00\00\01\00\00\00\01\00\01"
    "\01\00\01\01\01\01\01\01\00\01" "\00\01\01\01\01\01\00\01\00\01"
    "\01\00\00\00\00\00\00\00\00\01" "\00\00\08\00\00\01\00\00\00\01"
    "\01\01\01\01\01\01\00\01\01\01" "\01\01\04\01\01\01\01\01\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"    
    ;; 157888 | maze_008_20x20 = 400 bytes
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    "\01\00\03\04\05\06\07\08\02\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"

    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\01"
    "\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01"
    ;; 158288 | maze_cleared_data_trophy = 16 bytes | 0 = false 1 = true
    "\00\00\00\00"
    "\00\00\00\00"
    "\00\00\00\00"
    "\00\00\00\00" ;; the last 3 bytes are for padding
    ;; 158304 | maze_lucky_trophy = 16 bytes | 0 = false 1 = true
    "\00\00\00\00"
    "\00\00\00\00"
    "\00\00\00\00"
    "\00\00\00\00" ;; the last 3 bytes are for padding
    ;; 158320 | data_notes = 16 bytes
    "\06\01" ;; 262 = DO C4 (Middle C)
    "\26\01" ;; 294 = RE D4
    "\4A\01" ;; 330 = MI E4
    "\5D\01" ;; 349 = FA F4
    "\88\01" ;; 392 = SO (Sol) G4
    "\B8\01" ;; 440 = LA A4
    "\EE\01" ;; 494 = TI (Si) B4
    "\0B\02" ;; 523 = DO C5 (High C)
    ;; 158336 | color_mixer = 4 bytes
    "\00\00\00\FF"
    ;; 158340 | counter_256_up = 4 byte
    "\00" ;; timer_01_032_step
    "\00" ;; timer_02_064_step
    "\00" ;; timer_03_128_step
    "\00" ;; timer_04_256_step
    ;; 158344 | pointer_x and pointer_y = 4 bytes
    "\FF\FF\00\00" ;; the last 2 bytes are for padding
    ;; 158348 | key obtain status (red, green, blue) = 4 bytes
    "\00\00\00\00" ;; the last byte is for padding
    ;; 158352 | reserved for future data
  )
)

