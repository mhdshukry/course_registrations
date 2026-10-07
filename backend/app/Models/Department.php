<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Department extends Model
{
    use HasFactory;

    protected $primaryKey = 'department_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'department_id',
        'faculty_id',
        'department_code',
        'department_name',
        'status',
    ];

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class, 'faculty_id', 'faculty_id');
    }

    public function programmes(): HasMany
    {
        return $this->hasMany(Programme::class, 'department_id', 'department_id');
    }

    public function courses(): HasMany
    {
        return $this->hasMany(Course::class, 'owning_department_id', 'department_id');
    }

    public function staff(): HasMany
    {
        return $this->hasMany(Staff::class, 'department_id', 'department_id');
    }
}
