<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CoursePrerequisite extends Model
{
    use HasFactory;

    protected $primaryKey = 'prerequisite_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'prerequisite_id',
        'course_id',
        'prerequisite_course_id',
        'minimum_grade',
        'rule_type',
    ];

    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class, 'course_id', 'course_id');
    }

    public function prerequisiteCourse(): BelongsTo
    {
        return $this->belongsTo(Course::class, 'prerequisite_course_id', 'course_id');
    }
}
