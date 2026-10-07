<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimetableSlot extends Model
{
    use HasFactory;

    protected $primaryKey = 'timetable_slot_id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'timetable_slot_id',
        'group_id',
        'day_of_week',
        'start_time',
        'end_time',
        'venue',
    ];

    public function group(): BelongsTo
    {
        return $this->belongsTo(CourseGroup::class, 'group_id', 'group_id');
    }

    /**
     * Check if this slot clashes with another slot
     */
    public function clashesWith(TimetableSlot $other): bool
    {
        if (strcasecmp($this->day_of_week, $other->day_of_week) !== 0) {
            return false;
        }

        $thisStart = strtotime($this->start_time);
        $thisEnd = strtotime($this->end_time);
        $otherStart = strtotime($other->start_time);
        $otherEnd = strtotime($other->end_time);

        return ($thisStart < $otherEnd) && ($otherStart < $thisEnd);
    }
}
