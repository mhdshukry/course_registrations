<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Faculty extends Model
{
    use HasFactory;

    protected $primaryKey = 'faculty_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'faculty_id',
        'faculty_code',
        'faculty_name',
        'status',
    ];

    public function departments(): HasMany
    {
        return $this->hasMany(Department::class, 'faculty_id', 'faculty_id');
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class, 'faculty_id', 'faculty_id');
    }
}
