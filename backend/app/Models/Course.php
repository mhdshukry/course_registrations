<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Course extends Model
{
    use HasFactory;

    protected $primaryKey = 'course_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'course_id',
        'course_code',
        'course_title',
        'description',
        'credit_value',
        'course_level',
        'owning_department_id',
        'course_status',
    ];

    protected $casts = [
        'credit_value' => 'integer',
        'course_level' => 'integer',
    ];

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class, 'owning_department_id', 'department_id');
    }

    public function offerings(): HasMany
    {
        return $this->hasMany(CourseOffering::class, 'course_id', 'course_id');
    }

    public function prerequisites(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'course_prerequisites', 'course_id', 'prerequisite_course_id', 'course_id', 'course_id')
            ->withPivot(['minimum_grade', 'rule_type']);
    }

    public function dependentCourses(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'course_prerequisites', 'prerequisite_course_id', 'course_id', 'course_id', 'course_id')
            ->withPivot(['minimum_grade', 'rule_type']);
    }

    public function curricula(): BelongsToMany
    {
        return $this->belongsToMany(Curriculum::class, 'curriculum_courses', 'course_id', 'curriculum_id', 'course_id', 'curriculum_id')
            ->withPivot(['semester_number', 'course_type', 'is_compulsory', 'elective_group_id']);
    }
}
