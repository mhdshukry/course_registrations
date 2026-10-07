<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Curriculum extends Model
{
    use HasFactory;

    protected $table = 'curricula';
    protected $primaryKey = 'curriculum_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'curriculum_id',
        'programme_id',
        'curriculum_name',
        'version',
        'effective_year',
        'total_credits',
        'status',
    ];

    public function programme(): BelongsTo
    {
        return $this->belongsTo(Programme::class, 'programme_id', 'programme_id');
    }

    public function curriculumCourses(): HasMany
    {
        return $this->hasMany(CurriculumCourse::class, 'curriculum_id', 'curriculum_id');
    }

    public function courses(): BelongsToMany
    {
        return $this->belongsToMany(Course::class, 'curriculum_courses', 'curriculum_id', 'course_id', 'curriculum_id', 'course_id')
            ->withPivot(['semester_number', 'course_type', 'is_compulsory', 'elective_group_id']);
    }
}
