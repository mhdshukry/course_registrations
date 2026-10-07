<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CourseOffering extends Model
{
    use HasFactory;

    protected $primaryKey = 'offering_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'offering_id',
        'course_id',
        'academic_year_id',
        'semester_id',
        'department_id',
        'lecturer_id',
        'capacity',
        'registration_count',
        'delivery_mode',
        'offering_status',
    ];

    protected $casts = [
        'capacity' => 'integer',
        'registration_count' => 'integer',
    ];

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class, 'course_id', 'course_id');
    }

    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id', 'academic_year_id');
    }

    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class, 'semester_id', 'semester_id');
    }

    public function lecturer(): BelongsTo
    {
        return $this->belongsTo(Staff::class, 'lecturer_id', 'staff_id');
    }

    public function groups(): HasMany
    {
        return $this->hasMany(CourseGroup::class, 'offering_id', 'offering_id');
    }

    public function waitingLists(): HasMany
    {
        return $this->hasMany(WaitingList::class, 'offering_id', 'offering_id');
    }

    public function isFull(): bool
    {
        return $this->registration_count >= $this->capacity;
    }

    public function availableSeats(): int
    {
        return max(0, $this->capacity - $this->registration_count);
    }
}
