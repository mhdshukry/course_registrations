<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CourseOffering;
use App\Models\WaitingList;
use App\Services\WaitingListService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WaitingListController extends Controller
{
    protected WaitingListService $waitingListService;

    public function __construct(WaitingListService $waitingListService)
    {
        $this->waitingListService = $waitingListService;
    }

    /**
     * Join waiting list for full offering
     */
    public function join(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'offering_id' => 'required|string',
        ]);

        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $offering = CourseOffering::findOrFail($validated['offering_id']);

        $entry = $this->waitingListService->joinWaitingList($student, $offering);

        return response()->json([
            'success' => true,
            'message' => "Successfully queued. Current waiting position: #{$entry->position}",
            'data' => $entry,
        ]);
    }

    /**
     * Cancel/Leave waiting list
     */
    public function leave(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'offering_id' => 'required|string',
        ]);

        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $entry = WaitingList::where('offering_id', $validated['offering_id'])
            ->where('student_id', $student->student_id)
            ->where('status', 'WAITING')
            ->first();

        if ($entry) {
            $pos = $entry->position;
            $offeringId = $entry->offering_id;

            $entry->update(['status' => 'CANCELLED']);

            // Compact positions
            WaitingList::where('offering_id', $offeringId)
                ->where('status', 'WAITING')
                ->where('position', '>', $pos)
                ->decrement('position');

            return response()->json(['success' => true, 'message' => 'Removed from waiting list.']);
        }

        return response()->json(['success' => false, 'message' => 'Entry not found.'], 404);
    }

    /**
     * Get active student's waiting list queues
     */
    public function myWaitingLists(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $lists = WaitingList::with('offering.course')
            ->where('student_id', $student->student_id)
            ->latest('joined_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $lists,
        ]);
    }

    /**
     * Claim a promoted seat from the waiting list
     */
    public function claim(Request $request, string $id): JsonResponse
    {
        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        try {
            $result = $this->waitingListService->claimPromotedSeat($student, $id);
            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }
}
