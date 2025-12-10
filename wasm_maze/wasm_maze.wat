;; Kenny Fully made this example. May GOD bless you.
(module
  (import "sound" "playDataSound" (func $play_data_sound (param i32)))
  (memory (export "memory") 3) ;; 196608 bytes
  (global $camera_x i32 (i32.const 72))
  (global $camera_y i32 (i32.const 72))
  (global $countup (mut i32) (i32.const 0))
  (global $gamebox_height i32 (i32.const 160))
  (global $gamebox_width i32 (i32.const 160))
  (global $gamebox_area i32 (i32.const 25600)) ;; gamebox_width * gamebox_height
  (global $has_key_blue (mut i32) (i32.const 0))
  (global $has_key_green (mut i32) (i32.const 0))
  (global $has_key_red (mut i32) (i32.const 0))
  (global $maze_cleared (mut i32) (i32.const 0))
  (global $maze_index (mut i32) (i32.const 0))
  (global $maze_selected (mut i32) (i32.const 0))
  (global $player_hitbox_size i32 (i32.const 10))
  (global $player_mode (mut i32) (i32.const 0))
  (global $player_lucky (mut i32) (i32.const 0))
  (global $player_size (mut i32) (i32.const 16))
  (global $player_x (mut i32) (i32.const 16))
  (global $player_y (mut i32) (i32.const 16))
  (global $pointer_x (export "pointer_x") (mut i32) (i32.const 255))
  (global $pointer_y (export "pointer_y") (mut i32) (i32.const 255))
  (global $scene_index (mut i32) (i32.const 0)) ;; current scene 0 = Title; 1 = Maze Select; 2 = Game
  (global $timer_30 (mut i32) (i32.const 0)) ;; 30 frame counter
  (global $timer_60 (mut i32) (i32.const 0)) ;; 60 frame counter
  (global $timer_cooldown_15 (mut i32) (i32.const 0)) ;; used for limiting repeating sounds
  (global $title_image_loaded (mut i32) (i32.const 0)) ;; check to see if title image loaded
  ;; color format ABGR
  (global $clear i32 (i32.const 0x00000000))
  (global $white i32 (i32.const 0xFFFFFFFF))
  (global $red_light i32 (i32.const 0xFF3B3BFF))
  (global $red i32 (i32.const 0xFF0000FF))
  (global $red_dark i32 (i32.const 0xFF000080))
  (global $yellow i32 (i32.const 0xFF00FFFF))
  (global $yellow_dark i32 (i32.const 0xFF008080))
  (global $green i32 (i32.const 0xFF00FF00))
  (global $green_dark i32 (i32.const 0xFF008000))
  (global $blue i32 (i32.const 0xFFFF0000))
  (global $blue_dark i32 (i32.const 0xFF800000))
  (global $wasm_blue i32 (i32.const 0xFFF04F65))
  (global $black i32 (i32.const 0xFF000000))
  (global $brown_light i32 (i32.const 0xFF9CE1FF))
  
  ;; mathmatic abs function
  (func $i32_abs (param $value i32) (result i32)
    local.get $value
    i32.const 0
    i32.lt_s
    if
      i32.const 0
      local.get $value
      i32.sub
      return
    end
    local.get $value
  )

  (func $color_switcher (param $color_01 i32) (param $color_02 i32) (result i32)
    global.get $timer_60
    i32.const 29
    i32.lt_s
    if
      local.get $color_01
      return
    end
    local.get $color_02
  )

  (func $color_switcher_3 (param $color_01 i32) (param $color_02 i32) (param $color_03 i32) (result i32)
    global.get $timer_30
    i32.const 9
    i32.lt_s
    if
      local.get $color_01
      return
    end
    global.get $timer_30
    i32.const 19
    i32.lt_s
    if
      local.get $color_02
      return
    end
    local.get $color_03
  )

  (func $sound_switcher_3
    global.get $timer_30
    i32.const 9
    i32.lt_s
    if
      global.get $timer_cooldown_15
      i32.const 0
      i32.eq
      if
        i32.const 9
        global.set $timer_cooldown_15
        i32.const 141721
        i32.load16_u
        call $play_data_sound
      end
    else
      global.get $timer_30
      i32.const 19
      i32.lt_s
      if
        global.get $timer_cooldown_15
        i32.const 0
        i32.eq
        if
          i32.const 9
          global.set $timer_cooldown_15
          i32.const 141723
          i32.load16_u
          call $play_data_sound
        end
      else
        global.get $timer_cooldown_15
        i32.const 0
        i32.eq
        if
          i32.const 9
          global.set $timer_cooldown_15
          i32.const 141725
          i32.load16_u
          call $play_data_sound
        end
      end
    end    
  )

  ;; calculate a tile's X-position on the grid (column * tile_size)
  (func $get_tile_map_x (param $i i32) (result i32)
    local.get $i
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    global.get $camera_x
    i32.add
    global.get $player_x
    i32.sub
  )

  ;; calculate a tile's Y-position on the grid (row * tile_size)
  (func $get_tile_map_y (param $i i32) (result i32)
    local.get $i
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    global.get $camera_y
    i32.add
    global.get $player_y
    i32.sub
  )

  ;; calculates the absolute memory address of the tile data at index $i
  (func $get_tile_data_address (param $i i32) (result i32)
    i32.const 400
    global.get $maze_index
    i32.mul
    i32.const 138121   
    i32.add
    local.get $i
    i32.add
  )

  (func $pushback_player
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
      i32.const 15
      global.set $timer_cooldown_15
      i32.const 141721
      i32.load16_u
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

  (func $render_wasm_block
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; wasm_block_dx
    call $get_tile_map_x
    local.get $i         ;; wasm_block_dy
    call $get_tile_map_y
    i32.const 16         ;; wasm_block_dw
    i32.const 16         ;; wasm_block_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    global.get $clear ;; color_04
    global.get $clear ;; color_05
    i32.const 128768  ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_sweet_rock
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    (param $color_04 i32)
    (param $color_05 i32)
    local.get $i         ;; sweet_rock_dx
    call $get_tile_map_x
    local.get $i         ;; sweet_rock_dy
    call $get_tile_map_y
    i32.const 16         ;; sweet_rock_dw
    i32.const 16         ;; sweet_rock_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    local.get $color_04 ;; color_04
    local.get $color_05 ;; color_05
    i32.const 128512    ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_key
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_dx
    call $get_tile_map_x
    local.get $i         ;; key_dy
    call $get_tile_map_y
    i32.const 16         ;; key_dw
    i32.const 16         ;; key_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    global.get $clear ;; color_04
    global.get $clear ;; color_05
    i32.const 131584  ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_lock
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_red_dx
    call $get_tile_map_x
    local.get $i         ;; key_red_dy
    call $get_tile_map_y
    i32.const 16         ;; key_red_dw
    i32.const 16         ;; key_red_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    global.get $clear ;; color_04
    global.get $clear ;; color_05
    i32.const 131840  ;; data_address
    call $render_color_indexed_sprite
  )

  ;; gray out the entire screen
  (func $gray_screen
    i32.const 0
    i32.const 127
    i32.const 102400
    memory.fill
  )

  ;; clear the entire screen
  (func $clear_screen
    i32.const 0
    i32.const 0
    i32.const 102400
    memory.fill
  )

  (func $player_to_object_collision (param $i i32) (result i32)
    global.get $player_x
    i32.const 3
    i32.add
    global.get $player_y
    i32.const 6
    i32.add
    global.get $player_hitbox_size ;; 10
    ;; object_x
    local.get $i
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    ;; object_y
    local.get $i
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    ;; object_size
    i32.const 16
    call $square_collision
    i32.const 1 ;; check for true
    i32.eq
  )

  (func $check_item_on_map (param $i i32) (param $item_index i32) (result i32)
    i32.const 400
    global.get $maze_index
    i32.mul
    i32.const 138121
    i32.add
    local.get $i
    i32.add
    i32.load8_u
    local.get $item_index
    i32.eq
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
          ;; set maze_cleared
          i32.const 1
          global.set $maze_cleared
          ;; add trophy to the maze button if maze level is less than 8
          global.get $maze_index
          i32.const 8
          i32.lt_s
          if
            i32.const 138112 ;; address for trophies
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
        local.get $i
        call $player_to_object_collision
        if          
          i32.const 141723
          i32.load16_u
          call $play_data_sound

          i32.const 400
          global.get $maze_index
          i32.mul
          i32.const 138121
          i32.add
          local.get $i
          i32.add        
          i32.const 0x09 ;; indicates key_red is picked up
          i32.store8
          i32.const 1
          global.set $has_key_red
        end
      end

      ;; check if a key_green collides
      local.get $i
      i32.const 4
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if          
          i32.const 141723
          i32.load16_u
          call $play_data_sound

          i32.const 400
          global.get $maze_index
          i32.mul
          i32.const 138121
          i32.add
          local.get $i
          i32.add        
          i32.const 0x0A ;; indicates key_green is picked up
          i32.store8
          i32.const 1
          global.set $has_key_green
        end
      end

      ;; check if a key_blue collides
      local.get $i
      i32.const 5
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if          
          i32.const 141723
          i32.load16_u
          call $play_data_sound

          i32.const 400
          global.get $maze_index
          i32.mul
          i32.const 138121
          i32.add
          local.get $i
          i32.add        
          i32.const 0x0B ;; indicates key_blue is picked up
          i32.store8
          i32.const 1
          global.set $has_key_blue
        end
      end

      ;; check if a lock_red collides
      local.get $i
      i32.const 6
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          global.get $has_key_red
          i32.const 1
          i32.eq
          if          
            i32.const 141725
            i32.load16_u
            call $play_data_sound

            i32.const 400
            global.get $maze_index
            i32.mul
            i32.const 138121
            i32.add
            local.get $i
            i32.add        
            i32.const 0x0C ;; indicates lock_red is unlocked
            i32.store8
            i32.const 0
            global.set $has_key_red
          else
            call $pushback_player
          end
        end
      end
      
      ;; check if a lock_green collides
      local.get $i
      i32.const 7
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          global.get $has_key_green
          i32.const 1
          i32.eq
          if          
            i32.const 141725
            i32.load16_u
            call $play_data_sound

            i32.const 400
            global.get $maze_index
            i32.mul
            i32.const 138121
            i32.add
            local.get $i
            i32.add        
            i32.const 0x0D ;; indicates lock_red is unlocked
            i32.store8
            i32.const 0
            global.set $has_key_green
          else
            call $pushback_player
          end
        end
      end
      
      ;; check if a lock_blue collides
      local.get $i
      i32.const 8
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          global.get $has_key_blue
          i32.const 1
          i32.eq
          if          
            i32.const 141725
            i32.load16_u
            call $play_data_sound

            i32.const 400
            global.get $maze_index
            i32.mul
            i32.const 138121
            i32.add
            local.get $i
            i32.add        
            i32.const 0x0E ;; indicates lock_red is unlocked
            i32.store8
            i32.const 0
            global.set $has_key_blue
          else
            call $pushback_player
          end
        end
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

  ;; render map
  (func $render_map (local $i i32)
    loop $loop
      ;; check for sweet_rock
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 1
      i32.eq
      if
        local.get $i
        global.get $black        ;; color_01
        global.get $white        ;; color_02
        global.get $red_light
        global.get $red
        global.get $red_dark
        call $color_switcher_3   ;; color_03
        global.get $wasm_blue    ;; color_04
        global.get $brown_light  ;; color_05
        call $render_sweet_rock
      end
      ;; check for wasm_block
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 2
      i32.eq
      if
        local.get $i
        global.get $blue
        global.get $wasm_blue
        call $color_switcher ;; color_01
        global.get $white    ;; color_02
        global.get $clear    ;; color_03
        call $render_wasm_block
      end
      ;; check for key_red
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 3
      i32.eq
      if
        local.get $i
        global.get $red
        global.get $red_dark
        call $color_switcher ;; color_01
        global.get $clear    ;; color_02
        global.get $clear    ;; color_03
        call $render_key
      end
      ;; check for key_green
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 4
      i32.eq
      if
        local.get $i
        global.get $green
        global.get $green_dark
        call $color_switcher ;; color_01
        global.get $clear    ;; color_02
        global.get $clear    ;; color_03
        call $render_key
      end
      ;; check for key_blue
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 5
      i32.eq
      if
        local.get $i
        global.get $blue
        global.get $blue_dark
        call $color_switcher ;; color_01
        global.get $clear    ;; color_02
        global.get $clear    ;; color_03
        call $render_key
      end
      ;; check for lock_red
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 6
      i32.eq
      if
        local.get $i
        global.get $red      ;; color_01
        global.get $yellow   ;; color_02
        global.get $clear    ;; color_03
        call $render_lock
      end
      ;; check for lock_green
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 7
      i32.eq
      if
        local.get $i
        global.get $green_dark ;; color_01
        global.get $yellow     ;; color_02
        global.get $clear      ;; color_03
        call $render_lock
      end
      ;; check for lock_blue
      local.get $i
      call $get_tile_data_address
      i32.load8_u
      i32.const 8
      i32.eq
      if
        local.get $i
        global.get $blue     ;; color_01
        global.get $yellow   ;; color_02
        global.get $clear    ;; color_03
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

  (func $check_for_lucky (result i32 i32 i32)
    global.get $player_lucky
    i32.const 1
    i32.eq
    if
      global.get $red_dark
      global.get $red
      global.get $yellow
      return
    end
    global.get $black
    global.get $wasm_blue
    global.get $white
  )
  
  (func $render_player
    global.get $timer_30
    i32.const 14
    i32.lt_s
    if
      global.get $camera_x
      global.get $camera_y
      i32.const 16
      i32.const 16
      call $check_for_lucky
      global.get $red
      global.get $clear
      i32.const 129024
      global.get $player_mode
      i32.const 512
      i32.mul
      i32.add
      call $render_color_indexed_sprite
    else
      global.get $camera_x
      global.get $camera_y
      i32.const 16
      i32.const 16
      call $check_for_lucky
      global.get $red
      global.get $clear
      i32.const 129280
      global.get $player_mode
      i32.const 512
      i32.mul
      i32.add
      call $render_color_indexed_sprite
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
          global.get $gamebox_height
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
              global.get $gamebox_width
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
                  global.get $gamebox_width
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

  ;; TITLE_SCENE
  (func $title_scene (local $i i32)
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
      global.get $white
      global.get $wasm_blue
      global.get $red
      global.get $clear
      global.get $clear
      i32.const 102400
      call $render_color_indexed_sprite
    end
	;; check to see if $countup is 179
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

  ;; MAZE_SELECT_SCENE
  (func $maze_select_scene (local $i i32)
    global.get $maze_selected
    i32.const 0
    i32.eq
      if
        call $clear_screen
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
          global.get $wasm_blue
          global.get $yellow
          global.get $clear
          global.get $clear
          global.get $clear
          i32.const 132160          
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
          global.get $red
          global.get $clear
          global.get $clear
          global.get $clear
          global.get $clear
          i32.const 133184
          local.get $i
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 138112
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
            global.get $wasm_blue
            global.get $clear
            global.get $clear
            global.get $clear
            global.get $clear
            i32.const 135488 
            call $render_color_indexed_sprite
          end
          ;; check col
          ;; pointer
          global.get $pointer_x
          global.get $pointer_y
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
              i32.const 16 
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

            local.get $i
            i32.const 8
            i32.eq
            if
              i32.const 16
              global.set $player_x
              i32.const 16 
              global.set $player_y
            end

            local.get $i
            i32.const 9
            i32.eq
            if
              i32.const 16
              global.set $player_x
              i32.const 16 
              global.set $player_y
            end

            local.get $i
            i32.const 0
            i32.eq
            if
              i32.const 16
              global.set $player_x
              i32.const 16 
              global.set $player_y
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
        i32.const 179
	    i32.lt_s
        if
          call $gray_screen
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
          global.get $wasm_blue
          global.get $yellow
          global.get $clear
          global.get $clear
          global.get $clear
          i32.const 132160
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
          global.get $red
          global.get $clear
          global.get $clear
          global.get $clear
          global.get $clear
          i32.const 133184
          global.get $maze_index
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 138112
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
            global.get $wasm_blue
            global.get $clear
            global.get $clear
            global.get $clear
            global.get $clear
            i32.const 135488             
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

  ;; GAME_SCENE
  (func $game_scene
    call $clear_screen
    ;; check to see if maze cleared
    global.get $maze_cleared
    i32.const 1
    i32.eq
    if
      ;; if maze cleared just show the you win modal
      i32.const 40      ;; dx
      i32.const 64      ;; dy
      i32.const 80      ;; dw
      i32.const 32      ;; dh
      global.get $red_dark
      global.get $green_dark
      global.get $blue_dark
      call $color_switcher_3 ;; color_01
      global.get $red   ;; color_02
      global.get $blue  ;; color_03
      global.get $clear ;; color_04
      global.get $clear ;; color_05
      i32.const 135552  ;; data_address
      call $render_color_indexed_sprite
      call $sound_switcher_3
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
      call $render_map
      call $render_player
      global.get $has_key_red
      i32.const 1
      i32.eq
      if
        i32.const 0
        i32.const 0
        i32.const 8
        i32.const 8
        global.get $red
        global.get $clear
        global.get $clear
        global.get $clear
        global.get $clear
        i32.const 132096
        call $render_color_indexed_sprite
      end

      global.get $has_key_green
      i32.const 1
      i32.eq
      if
        i32.const 8
        i32.const 0
        i32.const 8
        i32.const 8
        global.get $green_dark
        global.get $clear
        global.get $clear
        global.get $clear
        global.get $clear
        i32.const 132096
        call $render_color_indexed_sprite
      end

      global.get $has_key_blue
      i32.const 1
      i32.eq
      if
        i32.const 16
        i32.const 0
        i32.const 8
        i32.const 8
        global.get $blue
        global.get $clear
        global.get $clear
        global.get $clear
        global.get $clear
        i32.const 132096
        call $render_color_indexed_sprite
      end
      ;; update player pos
      global.get $pointer_x
      i32.const 255
      i32.ne
      if
        global.get $pointer_y
        i32.const 80 ;; half of the screen 
        i32.sub
        call $i32_abs
        global.get $pointer_x
        i32.const 80 ;; half of the screen 
        i32.sub
        call $i32_abs
        i32.gt_s
        if
          global.get $pointer_y
          global.get $camera_y
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
          global.get $pointer_x
          global.get $camera_x
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
  )

  ;; game loop
  (func (export "render_frame")  
    global.get $scene_index
	i32.const 0
	i32.eq
	if
      call $title_scene
	end
    global.get $scene_index
	i32.const 1
	i32.eq
	if
      call $maze_select_scene
	end
    global.get $scene_index
	i32.const 2
	i32.eq
	if
      call $game_scene
	end
    ;; render pointer
    global.get $timer_30
    i32.const 14
    i32.lt_s
    if
      global.get $pointer_x
      i32.const 8
      i32.sub
      global.get $pointer_y
      i32.const 8
      i32.sub
      i32.const 16
      i32.const 16
      global.get $black
      global.get $yellow
      global.get $clear
      global.get $clear
      global.get $clear
      i32.const 128000
      call $render_color_indexed_sprite
    else
      global.get $pointer_x
      i32.const 8
      i32.sub
      global.get $pointer_y
      i32.const 8
      i32.sub
      i32.const 16
      i32.const 16
      global.get $black
      global.get $yellow
      global.get $clear
      global.get $clear
      global.get $clear
      i32.const 128256
      call $render_color_indexed_sprite
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

  (data (i32.const 102400)
    ;; 102400
    ;; title_160x160 = 25600 bytes      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\01\02\02\02\02\01\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\02\01\02\01\02\02\01\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\01\01\01\01\02\01\01\01\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\02\01\02\02\01\02\01\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01\01\01\01\01\01\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"

    ;; 128000
    ;; pointer_16x16_f1 = 256 bytes
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
    ;; 128256
    ;; pointer_16x16_f2 = 256 bytes
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
    ;; 128512
    ;; sweet_rock_16x16 = 256 bytes
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
    ;; 128768
    ;; wasm_block_16x16 = 256 bytes
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
    ;; 129024
    ;; player_idle_16x16_f1 = 256 bytes
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
    ;; 129280
    ;; player_idle_16x16_f2 256
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
    ;; 129536
    ;; player_up_16x16_f1 = 256 bytes
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
    ;; 129792
    ;; player_up_16x16_f2 = 256 bytes
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
    ;; 130048
    ;; player_down_16x16_f1 = 256 bytes
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
    ;; 130304
    ;; player_down_16x16_f2 = 256 bytes
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
    ;; 130560
    ;; player_left_16x16_f1 = 256 bytes
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
    ;; 130816
    ;; player_left_16x16_f2 = 256 bytes
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
    ;; 131072
    ;; player_right_16x16_f1 = 256 bytes
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
    ;; 131328
    ;; player_right_16x16_f2 = 256 bytes
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
    ;; 131584
    ;; key_16x16 = 256 bytes
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
    ;; 131840
    ;; lock_16x16 = 256 bytes
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
    ;; 132096
    ;; lock_icon_8x8_dc2 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\01\01\01\01\00\00"
    "\00\00\01\02\02\01\00\00"
    "\00\00\01\01\01\01\00\00"
    ;; 132160
    ;; maze_select_button_32x32 = 1024 bytes
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
    ;; 133184
    ;; maze_select_button_number_label_16x16x9 = 2304 bytes

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
    ;; 135488
    ;; maze_select_button_trophy_icon_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\01\00\00\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 135552
    ;; you_win_overlay_80x32 = 2560 bytes
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
    ;; 138112
    ;; maze_cleared_data_trophy = 9 bytes
    ;; 0 = false 1 = true
    "\00\00\00"
    "\00\00\00"
    "\00\00\00"

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
  
    ;; 138121
    ;; maze_000_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\06" "\00" "\01" "\02" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"

    "\01" "\05" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\08"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\00" "\01" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\07"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\03" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\04" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 138521
    ;; maze_001_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\02" "\00" "\00" "\01" "\05" "\00" "\00" "\00" "\01"   "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\04" "\00" "\01"
    "\01" "\01" "\01" "\07" "\01" "\01" "\01" "\00" "\01" "\01"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\06" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"

    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\03" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\08" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 138921
    ;; maze_002_20x20 = 400 bytes    
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\04" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\07" "\03" "\01"
    "\01" "\08" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"

    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\02" "\06" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\05" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 139321
    ;; maze_003_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00"   "\00" "\03" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\08" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\01" "\00" "\01"
    "\01" "\02" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\05" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\07" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01"
    "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\00"   "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\04" "\01" "\00"   "\00" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01"   "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\06" "\01"   "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 139721
    ;; maze_004_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\02" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 140121
    ;; maze_005_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\02" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 140521
    ;; maze_006_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\02" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 140921
    ;; maze_007_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\02" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 141321
    ;; maze_008_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\03" "\04" "\05" "\06" "\07" "\08" "\02" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 141721
    ;; data_notes = 16 bytes
    "\06\01" ;; 262 = DO C4 (Middle C)
    "\26\01" ;; 294 = RE D4
    "\4A\01" ;; 330 = MI E4
    "\5D\01" ;; 349 = FA F4
    "\88\01" ;; 392 = SO (Sol) G4
    "\B8\01" ;; 440 = LA A4
    "\EE\01" ;; 494 = TI (Si) B4
    "\0B\02" ;; 523 = DO C5 (High C)
  )
)

