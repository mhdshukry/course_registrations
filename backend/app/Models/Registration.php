<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Registration extends Model
{
    use HasFactory;

    protected $primaryKey = 'registration_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'registration_id',
        'student_id',
        'academic_year_id',
        'semester_id',
        'total_credits',
        'registration_status',
        'submitted_at',
        'approved_at',
        'locked_at',
        'verification_code',
    ];

    protected $casts = [
        'total_credits' => 'integer',
        'submitted_at' => 'datetime',
        'approved_at' => 'datetime',
        'locked_at' => 'datetime',
    ];

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class, 'student_id', 'student_id');
    }

    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id', 'academic_year_id');
    }

    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class, 'semester_id', 'semester_id');
    }

    public function registrationCourses(): HasMany
    {
        return $this->hasMany(RegistrationCourse::class, 'registration_id', 'registration_id');
    }

    public function approvals(): HasMany
    {
        return $this->hasMany(RegistrationApproval::class, 'registration_id', 'registration_id');
    }

    public function changes(): HasMany
    {
        return $this->hasMany(RegistrationChange::class, 'registration_id', 'registration_id');
    }

    public function specialRequests(): HasMany
    {
        return $this->hasMany(SpecialRequest::class, 'registration_id', 'registration_id');
    }

    public function recalculateCredits(): int
    {
        $total = 0;
        foreach ($this->registrationCourses as $regCourse) {
            if ($regCourse->course_status !== 'DROPPED') {
                $total += $regCourse->offering->course->credit_value ?? 0;
            }
        }
        $this->total_credits = $total;
        $this->save();
        return $total;
    }
}
