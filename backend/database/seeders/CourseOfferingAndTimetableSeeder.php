<?php

namespace Database\Seeders;

use App\Models\CourseGroup;
use App\Models\CourseOffering;
use App\Models\TimetableSlot;
use Illuminate\Database\Seeder;

class CourseOfferingAndTimetableSeeder extends Seeder
{
    public function run(): void
    {
        $offerings = [
            [
                'offering_id' => 'off_301',
                'course_id' => 'c301',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_lec',
                'capacity' => 60,
                'registration_count' => 45,
                'delivery_mode' => 'PHYSICAL',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_301_a',
                    'group_name' => 'Lecture Group A',
                    'group_type' => 'LECTURE',
                    'slots' => [
                        ['slot_id' => 'slot_301_1', 'day' => 'Monday', 'start' => '08:30:00', 'end' => '10:30:00', 'venue' => 'LT-01 Technology Complex'],
                    ],
                ],
            ],
            [
                'offering_id' => 'off_302',
                'course_id' => 'c302',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_lec',
                'capacity' => 40,
                'registration_count' => 38,
                'delivery_mode' => 'PHYSICAL',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_302_a',
                    'group_name' => 'Design Lab 1',
                    'group_type' => 'LAB',
                    'slots' => [
                        ['slot_id' => 'slot_302_1', 'day' => 'Tuesday', 'start' => '10:30:00', 'end' => '12:30:00', 'venue' => 'Multimedia Lab 2'],
                    ],
                ],
            ],
            [
                'offering_id' => 'off_303',
                'course_id' => 'c303',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_adv',
                'capacity' => 50,
                'registration_count' => 50, // FULL capacity to test waiting list!
                'delivery_mode' => 'HYBRID',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_303_a',
                    'group_name' => 'Web Studio',
                    'group_type' => 'PRACTICAL',
                    'slots' => [
                        ['slot_id' => 'slot_303_1', 'day' => 'Wednesday', 'start' => '13:30:00', 'end' => '15:30:00', 'venue' => 'Computer Lab 3'],
                    ],
                ],
            ],
            [
                'offering_id' => 'off_304',
                'course_id' => 'c304',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_hod',
                'capacity' => 60,
                'registration_count' => 52,
                'delivery_mode' => 'PHYSICAL',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_304_a',
                    'group_name' => 'AI Theory & Seminar',
                    'group_type' => 'LECTURE',
                    'slots' => [
                        ['slot_id' => 'slot_304_1', 'day' => 'Thursday', 'start' => '08:30:00', 'end' => '11:30:00', 'venue' => 'Main Auditorium FOT'],
                    ],
                ],
            ],
            [
                'offering_id' => 'off_305',
                'course_id' => 'c305',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_adv',
                'capacity' => 45,
                'registration_count' => 30,
                'delivery_mode' => 'PHYSICAL',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_305_a',
                    'group_name' => 'Cloud Systems Lab',
                    'group_type' => 'LAB',
                    'slots' => [
                        ['slot_id' => 'slot_305_1', 'day' => 'Thursday', 'start' => '13:30:00', 'end' => '16:30:00', 'venue' => 'Server & Cloud Lab'],
                    ],
                ],
            ],
            [
                'offering_id' => 'off_306',
                'course_id' => 'c306',
                'academic_year_id' => 'ay_2025',
                'semester_id' => 'sem_5',
                'department_id' => 'd_ict',
                'lecturer_id' => 'stf_lec',
                'capacity' => 60,
                'registration_count' => 58,
                'delivery_mode' => 'PHYSICAL',
                'offering_status' => 'OPEN',
                'group' => [
                    'group_id' => 'grp_306_a',
                    'group_name' => 'Mobile Dev Workshop',
                    'group_type' => 'PRACTICAL',
                    'slots' => [
                        ['slot_id' => 'slot_306_1', 'day' => 'Friday', 'start' => '08:30:00', 'end' => '11:30:00', 'venue' => 'Software Innovation Lab'],
                    ],
                ],
            ],
        ];

        foreach ($offerings as $data) {
            $groupData = $data['group'];
            unset($data['group']);

            $offering = CourseOffering::updateOrCreate(['offering_id' => $data['offering_id']], $data);

            $group = CourseGroup::updateOrCreate(
                ['group_id' => $groupData['group_id']],
                [
                    'offering_id' => $offering->offering_id,
                    'group_name' => $groupData['group_name'],
                    'group_type' => $groupData['group_type'],
                    'maximum_capacity' => $offering->capacity,
                ]
            );

            foreach ($groupData['slots'] as $slot) {
                TimetableSlot::updateOrCreate(
                    ['timetable_slot_id' => $slot['slot_id']],
                    [
                        'group_id' => $group->group_id,
                        'day_of_week' => $slot['day'],
                        'start_time' => $slot['start'],
                        'end_time' => $slot['end'],
                        'venue' => $slot['venue'],
                    ]
                );
            }
        }
    }
}
