# Escape Plan - Implementation Plan: Fix Bugs & Cải Thiện Game

## Mục Tiêu

Sửa bugs hiện có và implement các tính năng còn thiếu theo GDD, biến game từ prototype thành phiên bản chơi được hoàn chỉnh.

---

## User Review Required

> [!IMPORTANT]
> **Về LAN Multiplayer**: Multiplayer là tính năng lớn, đòi hỏi refactor toàn bộ kiến trúc (authority, sync, RPC). Plan này **KHÔNG bao gồm multiplayer** mà tập trung hoàn thiện single-player trước. Nếu bạn muốn thêm multiplayer, cần một plan riêng.

> [!IMPORTANT]
> **Về Outdoor Guards**: GDD đề cập "tội phạm canh giữ bên ngoài". Plan này sẽ tạo cơ sở (patrol system) để dễ dàng thêm outdoor enemy sau. Bạn có muốn implement đầy đủ outdoor guards trong plan này không?

> [!WARNING]
> **Về FOV/Lighting**: Hiệu ứng tầm nhìn giới hạn dùng `CanvasModulate` + `PointLight2D` yêu cầu map phải có `LightOccluder2D` trên tường để ánh sáng bị chặn. Map hiện tại (`map_01.tscn`) có thể cần thêm occluders. Điều này có thể mất thời gian tùy độ phức tạp của map.

---

## Proposed Changes

### Phase 1: Fix Bugs & Kết Nối Logic Cơ Bản

*Mục tiêu: Sửa tất cả bugs đã phát hiện, kết nối win/lose conditions*

---

#### [MODIFY] [door_zone.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/rooms/door_zone.gd)
- **Bug Fix**: Đổi `"player"` → `"Player"` (line 23) để match với Global Group

#### [MODIFY] [player_controller.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/player/player_controller.gd)
- **Typo Fix**: Đổi `deal_damge()` → `deal_damage()` (line 66)
- **Thêm**: Signal `health_changed(new_health)` để UI cập nhật
- **Thêm**: Gọi `GameManager.trigger_game_over()` khi health = 0
- **Thêm**: Hiệu ứng invincibility frames sau khi nhận damage (tránh bị spam damage)

#### [MODIFY] [MissionSystem.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/mission/MissionSystem.gd)
- **Typo Fix**: Rename các biến `rescuse` → `rescue` cho nhất quán
- **Logic Fix**: Kết nối win condition (line 144-146) → gọi `GameManager.trigger_win()`
- **Logic Fix**: Kết nối `time_up` signal → `GameManager.trigger_game_over()`

#### [MODIFY] [mission_ui.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/ui/mission_ui.gd)
- **Typo Fix**: Rename `set_rescuse` → `set_rescue`

#### [MODIFY] [GameManager.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/managers/GameManager.gd)
- **Thêm**: `player_health` tracking
- **Thêm**: Pause game khi game over / win
- **Thêm**: Signal `game_state_changed` để các hệ thống khác nhận biết

---

### Phase 2: Tầm Nhìn Giới Hạn (FOV System)

*Mục tiêu: Tạo cảm giác kinh dị bằng giới hạn tầm nhìn, tối toàn map, player chỉ thấy xung quanh*

---

#### [MODIFY] player.tscn / player_controller.gd
- **Thêm** `PointLight2D` làm child của Player:
  - Texture: radial gradient (soft circle)
  - Energy: 1.0, Range: ~300px
  - Tạo hiệu ứng đèn pin / tầm nhìn
- **Thêm** `CanvasModulate` vào map scene:
  - Color: rất tối (ví dụ `Color(0.05, 0.05, 0.1)`)
  - Tạo darkness toàn map

#### [MODIFY] map_01.tscn (thủ công trong Godot Editor)
- **Thêm** `LightOccluder2D` trên các tường
  - Để ánh sáng bị chặn bởi tường → player không thể nhìn xuyên tường
  - ⚠️ Phần này cần làm thủ công trong editor vì phụ thuộc tilemap

> [!NOTE]
> Phase này có thể cần bạn thao tác thủ công trong Godot Editor để thêm Light Occluders vào tilemap walls. Tôi sẽ tạo script helper và hướng dẫn chi tiết.

---

### Phase 3: Enemy AI Hoàn Thiện

*Mục tiêu: Enemy có đầy đủ behavior - tuần tra, phát hiện, truy đuổi, tấn công*

---

#### [MODIFY] [enemy_controller.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/enemy/enemy_controller.gd)

**3.1 - ATTACK State → Gây Damage**
```gdscript
# Khi ở ATTACK state:
ENEMY_STATE.ATTACK:
    direction = Vector2.ZERO
    attack_player()

func attack_player():
    if attack_cooldown_timer <= 0:
        player.deal_damage()  # Gọi hàm đã fix typo
        attack_cooldown_timer = attack_cooldown  # VD: 1.0s
```

**3.2 - PATROL State**
- Thêm `@export var patrol_points: Array[Node2D]` - danh sách waypoints tuần tra
- Khi IDLE → chuyển sang PATROL
- Di chuyển tuần hoàn giữa các patrol points
- Khi phát hiện player (trigger area) → chuyển CHASE

```gdscript
ENEMY_STATE.PATROL:
    if patrol_points.is_empty():
        return
    var target = patrol_points[current_patrol_index]
    direction = position.direction_to(target.position)
    if position.distance_to(target.position) < 5:
        current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
        # Dừng lại 1-2s tại mỗi điểm
```

**3.3 - INVESTIGATE State**
- Khi nhận noise signal → di chuyển đến vị trí phát ra tiếng
- Nếu đến nơi mà không thấy player → quay lại patrol
- Nếu thấy player → chuyển CHASE

**3.4 - FOV Cone cho Enemy**
- Thêm `Area2D` hình cone phía trước enemy
- Player chỉ bị phát hiện khi nằm trong cone VÀ không bị tường chặn
- Thay thế trigger area hình tròn hiện tại

#### [MODIFY] [enemy_slime.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/ai/enemy_slime.gd)

Implement đầy đủ Slime enemy:
- **Behavior riêng**: Di chuyển chậm (SPEED ~150), phát hiện qua tiếng động (không cần line of sight)
- **States**: IDLE → WANDER (di chuyển ngẫu nhiên) → INVESTIGATE (nghe tiếng) → CHASE
- **Đặc điểm**: Có thể xuyên qua một số vật cản nhỏ, tầm nghe rộng hơn

---

### Phase 4: Noise System Hoàn Thiện

*Mục tiêu: Player phát ra tiếng khi hành động, enemy nghe và phản ứng*

---

#### [MODIFY] [NoiseManager.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/managers/NoiseManager.gd)
- Giữ signal system hiện tại
- **Thêm** noise intensity levels:
  - `SILENT` = 0 (crouch/đứng yên)
  - `SOFT` = 0.5 (đi bộ)
  - `LOUD` = 1.0 (chạy)
  - `VERY_LOUD` = 2.0 (tương tác door/cage)

#### [MODIFY] [player_controller.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/player/player_controller.gd)
- **Thêm** phát noise khi di chuyển:
  ```gdscript
  if input_dir != Vector2.ZERO:
      noise_timer -= delta
      if noise_timer <= 0:
          NoiseManager.emit_noise(global_position, 0.5)
          noise_timer = noise_interval  # VD: 0.5s
  ```

#### [MODIFY] [enemy_controller.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/enemy/enemy_controller.gd)
- **Thêm** lắng nghe NoiseManager:
  ```gdscript
  func _ready():
      NoiseManager.noise_emitted.connect(_on_noise_heard)

  func _on_noise_heard(pos: Vector2, intensity: float):
      var distance = global_position.distance_to(pos)
      var hearing_range = 300 * intensity
      if distance < hearing_range and state == ENEMY_STATE.PATROL:
          investigate_target = pos
          state = ENEMY_STATE.INVESTIGATE
  ```

---

### Phase 5: Prisoner System Cải Thiện

*Mục tiêu: Tù nhân có health, có thể bị tấn công, AI follow tốt hơn*

---

#### [MODIFY] [prisoner_ai.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/ai/prisoner_ai.gd)

**5.1 - Health System**
- **Thêm** `@export var health: int = 1`
- **Thêm** `signal prisoner_death(prisoner)`
- Khi health = 0 → emit signal → MissionSystem xử lý

**5.2 - Enemy có thể target Prisoner**
- Prisoner thuộc group `"Prisonner"` (đã có trong global_group)
- Enemy khi ở gần prisoner → có thể chuyển target sang prisoner

**5.3 - Follow AI Cải Thiện**
- **Thêm** simple obstacle avoidance bằng RayCast2D:
  ```gdscript
  # Nếu hướng đến player bị chặn → thử hướng khác
  var ray = $FollowRayCast
  ray.target_position = direction * 30
  ray.force_raycast_update()
  if ray.is_colliding():
      # Thử hướng lệch 45 độ
      direction = direction.rotated(PI/4)
  ```

#### [MODIFY] [MissionSystem.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/mission/MissionSystem.gd)
- **Thêm** xử lý prisoner death:
  ```gdscript
  func _on_prisoner_death(prisoner):
      pickUpPrisonners.erase(prisoner)
      prisoner.queue_free()
      # Check if all prisoners dead → game over
  ```

---

### Phase 6: Polish & Game Feel

*Mục tiêu: Hiệu ứng nâng cao trải nghiệm*

---

#### [MODIFY] [player_controller.gd](file:///d:/Codin/utc-code/HK3_2/AI/escape-plan/scripts/player/player_controller.gd)
- **Thêm** damage flash (nhấp nháy đỏ khi bị damage):
  ```gdscript
  func flash_damage():
      modulate = Color.RED
      await get_tree().create_timer(0.1).timeout
      modulate = Color.WHITE
  ```
- **Thêm** invincibility frames (0.5s sau khi nhận damage)

#### [NEW] camera_controller.gd
- Camera follow player với smoothing (`position_smoothing_enabled`)
- Screen shake khi bị damage
- Camera bounding (không ra ngoài map)

#### Particle Effects (thủ công trong Editor)
- Dust particles khi player di chuyển
- Glow effect cho keys
- Particle khi cage mở

---

## Open Questions

> [!IMPORTANT]
> 1. **Outdoor Guards**: Bạn có muốn implement đầy đủ loại enemy "tội phạm bên ngoài" trong plan này không? Hay để phase sau?

> [!IMPORTANT]
> 2. **FOV Style**: Bạn muốn tầm nhìn kiểu nào?
>    - **A) Đèn pin** (hình cone, hướng theo chiều di chuyển)
>    - **B) Vùng sáng tròn** (sáng đều xung quanh player)
>    - **C) Cả hai** (vùng sáng nhẹ xung quanh + đèn pin mạnh hơn theo hướng nhìn)

> [!IMPORTANT]
> 3. **Thứ tự thực hiện**: Plan được sắp xếp theo thứ tự ưu tiên (Phase 1 → 6). Bạn muốn implement tất cả hay chỉ một số phases cụ thể?

> [!IMPORTANT]  
> 4. **Enemy Slime behavior**: Bạn có ý tưởng cụ thể cho Slime enemy không? (tốc độ, cách phát hiện player, khả năng đặc biệt?)

---

## Verification Plan

### Automated Tests
- Chạy project trong Godot Editor, kiểm tra không có errors trong Output
- Test từng phase sau khi implement

### Manual Verification (theo từng Phase)

| Phase | Test Case |
|-------|-----------|
| 1 | Door zone hoạt động khi player đi vào |
| 1 | Player chết → chuyển sang GameOver scene |
| 1 | Rescue đủ tù nhân → chuyển sang WinScreen |
| 1 | Hết thời gian → game over |
| 2 | Map tối, chỉ sáng quanh player |
| 2 | Ánh sáng bị chặn bởi tường |
| 3 | Enemy tuần tra giữa các waypoints |
| 3 | Enemy truy đuổi khi phát hiện player |
| 3 | Enemy gây damage, player mất HP |
| 3 | Slime di chuyển và phản ứng |
| 4 | Enemy đi đến vị trí phát ra tiếng |
| 4 | Chạy tạo tiếng to hơn đi bộ |
| 5 | Prisoner bị enemy tấn công → chết |
| 5 | Prisoner follow không bị kẹt tường |
| 6 | Flash đỏ khi bị damage |
| 6 | Camera shake khi bị tấn công |
