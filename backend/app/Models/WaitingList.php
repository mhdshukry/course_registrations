<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WaitingList extends Model
{
    use HasFactory;

    protected $primaryKey = 'waiting_list_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'waiting_list_id',
        'offering_id',
        'student_id',
        'position',
        'status',
        'joined_at',
    ];

    protected $casts = [
        'position' => 'integer',
        'joined_at' => 'datetime',
    ];

    public function offering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class, 'offering_id', 'offering_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class, 'student_id', 'student_id');
    }
}
