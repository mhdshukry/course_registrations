<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CurriculumCourse extends Model
{
    use HasFactory;

    protected $primaryKey = 'curriculum_course_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'curriculum_course_id',
        'curriculum_id',
        'course_id',
        'semester_number',
        'course_type',
        'is_compulsory',
        'elective_group_id',
    ];

    protected $casts = [
        'is_compulsory' => 'boolean',
        'semester_number' => 'integer',
    ];

    public function curriculum(): BelongsTo
    {
        return $this->belongsTo(Curriculum::class, 'curriculum_id', 'curriculum_id');
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class, 'course_id', 'course_id');
    }
}
