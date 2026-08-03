## Table `users`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `full_name` | `text` |  Unique |
| `email` | `text` |  Unique |
| `is_active` | `bool` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |
| `avtar` | `text` |  Nullable |
| `role` | `text` |  |
| `last_expense_category_id` | `uuid` |  Nullable |

## Table `group`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  Nullable |
| `created_by` | `uuid` |  |
| `is_active` | `bool` |  Nullable |
| `is_deleted` | `bool` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |
| `created_at` | `timestamptz` |  |
| `deleted_at` | `timestamptz` |  Nullable |
| `group_type` | `group_type` |  |
| `group_icon` | `text` |  Nullable |
| `invite_code` | `text` |  |
| `destination` | `text` |  Nullable |
| `start_date` | `timestamptz` |  Nullable |
| `end_date` | `timestamptz` |  Nullable |
| `budget` | `numeric` |  Nullable |

## Table `group_member`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  Nullable |
| `user_id` | `uuid` |  |
| `group_id` | `uuid` |  |
| `role` | `user_role` |  |

## Table `friendship`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `requester_id` | `uuid` |  |
| `addressee_id` | `uuid` |  |
| `status` | `user_request_type` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |
| `is_read` | `bool` |  |

## Table `expense`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `group_id` | `uuid` |  Nullable |
| `created_by` | `uuid` |  |
| `description` | `text` |  |
| `total_amount` | `numeric` |  |
| `paid_by` | `uuid` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |
| `is_deleted` | `bool` |  Nullable |
| `expense_type` | `text` |  Nullable |
| `expense_note` | `text` |  Nullable |
| `updated_by` | `uuid` |  Nullable |
| `category_id` | `uuid` |  Nullable |
| `expense_scope` | `expense_scope` |  |
| `payment_method_id` | `uuid` |  Nullable |
| `expense_date` | `date` |  |

## Table `expense_split`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `expense_id` | `uuid` |  |
| `user_id` | `uuid` |  |
| `amount` | `numeric` |  |

## Table `app_feedback`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  Unique |
| `rating` | `int2` |  |
| `description` | `text` |  Nullable |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |

## Table `activity_log`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `entity_type` | `text` |  |
| `entity_id` | `uuid` |  Nullable |
| `action` | `text` |  |
| `group_id` | `uuid` |  Nullable |
| `reference_user_id` | `uuid` |  Nullable |
| `metadata` | `jsonb` |  Nullable |
| `created_at` | `timestamptz` |  |

## Table `expense_comment`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `expense_id` | `uuid` |  |
| `user_id` | `uuid` |  |
| `comment` | `text` |  |
| `created_at` | `timestamptz` |  Nullable |

## Table `expense_category`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  Unique |
| `icon` | `text` |  |
| `color` | `text` |  Nullable |
| `is_default` | `bool` |  |
| `is_active` | `bool` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |

## Table `user_category_limit`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  |
| `category_id` | `uuid` |  |
| `limit_amount` | `numeric` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |

## Table `expense_media`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `expense_id` | `uuid` |  |
| `media_url` | `text` |  |
| `public_id` | `text` |  |
| `media_type` | `text` |  |
| `file_name` | `text` |  Nullable |
| `file_size` | `int8` |  Nullable |
| `mime_type` | `text` |  Nullable |
| `width` | `int4` |  Nullable |
| `height` | `int4` |  Nullable |
| `created_by` | `uuid` |  |
| `created_at` | `timestamptz` |  |

## Table `payment_method`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  Unique |
| `icon` | `text` |  |
| `color` | `text` |  |
| `sort_order` | `int4` |  |
| `is_active` | `bool` |  |
| `created_at` | `timestamptz` |  |
| `updated_at` | `timestamptz` |  |

## Custom Types / Enums

### `user_role`

`user` | `admin` | `owner`

### `group_type`

`other` | `trip` | `home` | `couple`

### `user_request_type`

`pending` | `accepted` | `rejected` | `blocked`

### `expense_scope`

`group` | `personal` | `non_group`

### `user_access_role`

`user` | `admin`

## RLS Policies

### `users`

| Policy | Command | Roles | Action | USING | WITH CHECK |
|--------|---------|-------|--------|-------|------------|
| `Users can view own profile` | SELECT | public | PERMISSIVE | `(auth.uid() = id)` | — |
| `Users can insert own profile` | INSERT | public | PERMISSIVE | — | `(auth.uid() = id)` |
| `Users can update own profile` | UPDATE | public | PERMISSIVE | `(auth.uid() = id)` | `(auth.uid() = id)` |
| `Users can delete own profile` | DELETE | public | PERMISSIVE | `(auth.uid() = id)` | — |

