<?php

namespace App\Enums;

enum RegistrationStatusEnum: string
{
    case DRAFT = 'DRAFT';
    case SUBMITTED = 'SUBMITTED';
    case CHANGES_REQUESTED = 'CHANGES_REQUESTED';
    case ADVISER_APPROVED = 'ADVISER_APPROVED';
    case HOD_APPROVED = 'HOD_APPROVED';
    case FACULTY_APPROVED = 'FACULTY_APPROVED';
    case REGISTERED = 'REGISTERED';
    case LOCKED = 'LOCKED';

    public function isEditable(): bool
    {
        return in_array($this, [self::DRAFT, self::CHANGES_REQUESTED]);
    }

    public function isCompleted(): bool
    {
        return in_array($this, [self::REGISTERED, self::LOCKED]);
    }
}
