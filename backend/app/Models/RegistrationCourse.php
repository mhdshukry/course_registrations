<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegistrationCourse extends Model
{
    use HasFactory;

    protected $primaryKey = 'registration_course_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'registration_course_id',
        'registration_id',
        'offering_id',
        'group_id',
        'registration_type',
        'course_status',
        'added_at',
        'dropped_at',
    ];

    protected $casts = [
        'added_at' => 'datetime',
        'dropped_at' => 'datetime',
    ];

    public function registration(): BelongsTo
    {
        return $this->belongsTo(Registration::class, 'registration_id', 'registration_id');
    }

    public function offering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class, 'offering_id', 'offering_id');
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(CourseGroup::class, 'group_id', 'group_id');
    }
}
