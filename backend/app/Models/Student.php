<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Student extends Model
{
    use HasFactory;

    protected $primaryKey = 'student_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'student_id',
        'user_id',
        'registration_number',
        'faculty_id',
        'department_id',
        'programme_id',
        'curriculum_id',
        'intake_year',
        'current_level',
        'academic_status',
        'registration_eligibility',
        'min_credits',
        'max_credits',
    ];

    protected $casts = [
        'registration_eligibility' => 'boolean',
        'current_level' => 'integer',
        'min_credits' => 'integer',
        'max_credits' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'user_id');
    }

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class, 'faculty_id', 'faculty_id');
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class, 'department_id', 'department_id');
    }

    public function programme(): BelongsTo
    {
        return $this->belongsTo(Programme::class, 'programme_id', 'programme_id');
    }

    public function curriculum(): BelongsTo
    {
        return $this->belongsTo(Curriculum::class, 'curriculum_id', 'curriculum_id');
    }

    public function registrations(): HasMany
    {
        return $this->hasMany(Registration::class, 'student_id', 'student_id');
    }

    public function specialRequests(): HasMany
    {
        return $this->hasMany(SpecialRequest::class, 'student_id', 'student_id');
    }

    public function waitingLists(): HasMany
    {
        return $this->hasMany(WaitingList::class, 'student_id', 'student_id');
    }
}
