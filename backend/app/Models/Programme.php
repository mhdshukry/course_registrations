<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Programme extends Model
{
    use HasFactory;

    protected $primaryKey = 'programme_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'programme_id',
        'department_id',
        'programme_code',
        'programme_name',
        'degree_type',
        'duration_years',
        'total_credits',
        'status',
    ];

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class, 'department_id', 'department_id');
    }

    public function curricula(): HasMany
    {
        return $this->hasMany(Curriculum::class, 'programme_id', 'programme_id');
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class, 'programme_id', 'programme_id');
    }
}
