<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AcademicYear extends Model
{
    use HasFactory;

    protected $primaryKey = 'academic_year_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'academic_year_id',
        'year_name',
        'start_date',
        'end_date',
        'status',
    ];

    public function semesters(): HasMany
    {
        return $this->hasMany(Semester::class, 'academic_year_id', 'academic_year_id');
    }

    public function courseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class, 'academic_year_id', 'academic_year_id');
    }

    public function registrations(): HasMany
    {
        return $this->hasMany(Registration::class, 'academic_year_id', 'academic_year_id');
    }
}
