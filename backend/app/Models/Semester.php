<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Semester extends Model
{
    use HasFactory;

    protected $primaryKey = 'semester_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'semester_id',
        'academic_year_id',
        'semester_number',
        'semester_name',
        'start_date',
        'end_date',
        'status',
    ];

    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class, 'academic_year_id', 'academic_year_id');
    }

    public function courseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class, 'semester_id', 'semester_id');
    }

    public function registrations(): HasMany
    {
        return $this->hasMany(Registration::class, 'semester_id', 'semester_id');
    }
}
