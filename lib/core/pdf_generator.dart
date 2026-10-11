import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/models.dart';

class RuslPdfGenerator {
  static Future<Uint8List> generateRegistrationSlip({
    required StudentProfile student,
    required List<CourseOffering> selectedOfferings,
    required List<Course> allCourses,
    required String verificationToken,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RAJARATA UNIVERSITY OF SRI LANKA',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        student.facultyName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'OFFICIAL COURSE REGISTRATION SLIP',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber900,
                        ),
                      ),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://verify.rjt.ac.lk/reg/$verificationToken',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey400),
              pw.SizedBox(height: 12),

              // Student Info Grid
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfInfoRow(
                      'Student Name:',
                      student.fullName,
                      'Registration No:',
                      student.registrationNumber,
                    ),
                    pw.SizedBox(height: 6),
                    _buildPdfInfoRow(
                      'Degree Programme:',
                      student.programmeName,
                      'Curriculum:',
                      student.curriculumVersion,
                    ),
                    pw.SizedBox(height: 6),
                    _buildPdfInfoRow(
                      'Academic Level:',
                      'Level ${student.currentLevel}',
                      'Semester:',
                      'Semester ${student.currentSemester}',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Courses Table
              pw.Text(
                'Registered Courses & Modules',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  '#',
                  'Course Code',
                  'Course Title',
                  'Credits',
                  'Type',
                  'Lecturer In-Charge',
                ],
                data: List.generate(selectedOfferings.length, (index) {
                  final offering = selectedOfferings[index];
                  final course = allCourses.firstWhere(
                    (c) => c.id == offering.courseId,
                  );
                  return [
                    '${index + 1}',
                    course.code,
                    course.title,
                    '${course.creditValue}',
                    course.courseType.name.toUpperCase(),
                    offering.lecturerName,
                  ];
                }),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey800,
                ),
                cellHeight: 28,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.centerLeft,
                },
              ),
              pw.SizedBox(height: 16),

              // Total Credits Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Registered Credits: ',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '${selectedOfferings.fold(0, (sum, o) => sum + allCourses.firstWhere((c) => c.id == o.courseId).creditValue)} Credits',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfSignature('Student Signature'),
                  _buildPdfSignature('Head of Department (HoD) Endorsement'),
                  _buildPdfSignature('Assistant Registrar (Faculty)'),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Verification Token: $verificationToken • Official Rajarata University Academic Record',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfInfoRow(
    String label1,
    String val1,
    String label2,
    String val2,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$label1 ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.TextSpan(
                  text: val1,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        pw.Expanded(
          flex: 5,
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$label2 ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.TextSpan(
                  text: val2,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfSignature(String title) {
    return pw.Column(
      children: [
        pw.Container(width: 130, height: 1, color: PdfColors.grey500),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static Future<void> downloadPdf(
    StudentProfile student,
    List<CourseOffering> selectedOfferings,
    List<Course> allCourses,
    String verificationToken,
  ) async {
    final pdfBytes = await generateRegistrationSlip(
      student: student,
      selectedOfferings: selectedOfferings,
      allCourses: allCourses,
      verificationToken: verificationToken,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          'RUSL_Registration_${student.registrationNumber.replaceAll('/', '_')}.pdf',
    );
  }
}

class PdfSlipGenerator {
  static Future<void> downloadOrPrintPdf({
    required StudentProfile student,
    required List<Course> registeredCourses,
    required int totalCredits,
    required String academicYear,
    required int semesterNumber,
    required String verificationCode,
    required String status,
    String documentTitle = 'OFFICIAL COURSE REGISTRATION RECORD',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RAJARATA UNIVERSITY OF SRI LANKA',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        student.facultyName.toUpperCase(),
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        documentTitle,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber900,
                        ),
                      ),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'https://verify.rjt.ac.lk/reg/$verificationCode',
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.grey400),
              pw.SizedBox(height: 12),

              // Student Info Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Student Name: ${student.fullName}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Registration No: ${student.registrationNumber}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Degree: ${student.programmeName}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Status: $status',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Academic Year: $academicYear',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Semester: Semester $semesterNumber',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Course Table
              pw.Text(
                'Registered Courses & Modules',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: [
                  '#',
                  'Course Code',
                  'Course Title',
                  'Credits',
                  'Type',
                ],
                data: List.generate(registeredCourses.length, (index) {
                  final course = registeredCourses[index];
                  return [
                    '${index + 1}',
                    course.code,
                    course.title,
                    '${course.creditValue}',
                    course.courseType.name.toUpperCase(),
                  ];
                }),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey800,
                ),
                cellHeight: 28,
              ),
              pw.SizedBox(height: 16),

              // Total Credits Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Registered Credits: ',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.amber100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '$totalCredits Credits',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey500,
                      ),
                      pw.Text(
                        'Student Signature',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey500,
                      ),
                      pw.Text(
                        'HoD Endorsement',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 120,
                        height: 1,
                        color: PdfColors.grey500,
                      ),
                      pw.Text(
                        'Registrar Official Seal',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Verification Token: $verificationCode • Official Rajarata University Academic Record',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'RUSL_Record_${student.registrationNumber.replaceAll('/', '_')}.pdf',
    );
  }
}

class AdmissionCardPdfGenerator {
  static Future<Uint8List> generate({
    required StudentProfile student,
    required List<Course> courses,
    required String verificationCode,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              color: PdfColors.amber100,
              child: pw.Column(
                children: [
                  pw.Text(
                    'RAJARATA UNIVERSITY OF SRI LANKA',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('EXAMINATION ADMISSION CARD - 2025/2026 SEMESTER 1'),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            _admissionRow('Student', student.fullName),
            _admissionRow('Registration No.', student.registrationNumber),
            _admissionRow('Programme', student.programmeName),
            _admissionRow('Faculty', student.facultyName),
            _admissionRow('Examination Index', 'FOT/EX/2026/045'),
            pw.SizedBox(height: 18),
            pw.Text(
              'Approved Examination Modules',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: const ['Course Code', 'Course Title', 'Credits'],
              data: courses
                  .map(
                    (course) => [
                      course.code,
                      course.title,
                      '${course.creditValue}',
                    ],
                  )
                  .toList(),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Spacer(),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey500),
              ),
              child: pw.Text(
                'This admission is valid only with the University Identity Card. '
                'Verification code: $verificationCode',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                RuslPdfGenerator._buildPdfSignature('Candidate Signature'),
                RuslPdfGenerator._buildPdfSignature('Assistant Registrar'),
              ],
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  static pw.Widget _admissionRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 125,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );

  static Future<void> download({
    required StudentProfile student,
    required List<Course> courses,
    required String verificationCode,
  }) async {
    final bytes = await generate(
      student: student,
      courses: courses,
      verificationCode: verificationCode,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'RUSL_Admission_${student.registrationNumber.replaceAll('/', '_')}.pdf',
    );
  }
}
