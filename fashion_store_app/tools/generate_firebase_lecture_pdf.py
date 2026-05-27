"""One-off generator: Firebase integration lecture PDF for fashion_store_app."""
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
    PageBreak,
)


def p(text: str, style) -> Paragraph:
    # ReportLab Paragraph expects XML-ish escapes
    t = (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )
    return Paragraph(t, style)


def main() -> None:
    out = (
        Path(__file__).resolve().parent.parent
        / "Firebase_Integration_Lecture.pdf"
    )
    doc = SimpleDocTemplate(
        str(out),
        pagesize=LETTER,
        rightMargin=54,
        leftMargin=54,
        topMargin=54,
        bottomMargin=54,
    )
    styles = getSampleStyleSheet()
    title = ParagraphStyle(
        "T",
        parent=styles["Title"],
        fontSize=18,
        spaceAfter=14,
        textColor=colors.HexColor("#1A1D2E"),
    )
    h1 = ParagraphStyle(
        "H1",
        parent=styles["Heading1"],
        fontSize=14,
        spaceBefore=16,
        spaceAfter=8,
        textColor=colors.HexColor("#1A1D2E"),
    )
    h2 = ParagraphStyle(
        "H2",
        parent=styles["Heading2"],
        fontSize=11,
        spaceBefore=10,
        spaceAfter=6,
    )
    body = ParagraphStyle("B", parent=styles["Normal"], fontSize=10, leading=14)
    small = ParagraphStyle("S", parent=body, fontSize=9, leading=12, textColor=colors.grey)

    story: list = []

    story.append(p("Firebase in the Fashion Store App", title))
    story.append(
        p(
            "How Core, Auth, Firestore, Storage, and App Check connect in code — "
            "with file locations and reasons.",
            small,
        )
    )
    story.append(Spacer(1, 0.15 * inch))

    story.append(p("1. Pieces of the stack", h1))
    story.append(
        p(
            "<b>Firebase Core</b> — Initializes Firebase once; supplies project id, API keys, "
            "and storage bucket per platform (via firebase_options.dart).",
            body,
        )
    )
    story.append(
        p(
            "<b>Firebase Auth</b> — Email/password sign-in, registration, password reset, "
            "and listening for who is signed in.",
            body,
        )
    )
    story.append(
        p(
            "<b>Cloud Firestore</b> — Products, promo banners, user profiles, wishlists, "
            "and orders as documents and subcollections.",
            body,
        )
    )
    story.append(
        p(
            "<b>Firebase Storage</b> — Binary files (e.g. profile images); catalog can "
            "store a Storage path and resolve it to a download URL.",
            body,
        )
    )
    story.append(
        p(
            "<b>App Check</b> (release builds) — Helps ensure only your real app uses "
            "your backend; debug builds skip it for speed.",
            body,
        )
    )

    story.append(p("2. Dependencies (pubspec.yaml)", h1))
    story.append(
        p(
            "Packages: firebase_core, firebase_auth, cloud_firestore, firebase_storage, "
            "firebase_app_check. Reason: each Firebase product is a separate Flutter plugin.",
            body,
        )
    )

    story.append(p("3. Bootstrap — where Firebase starts", h1))
    story.append(
        p(
            "<b>lib/main.dart</b> — WidgetsFlutterBinding.ensureInitialized(); then "
            "Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform). "
            "On failure, shows an error screen instead of crashing. In release, activates App Check.",
            body,
        )
    )
    story.append(
        p(
            "<b>lib/firebase_options.dart</b> — Generated (e.g. FlutterFire CLI): "
            "FirebaseOptions for Android, iOS, Web, etc. Reason: one codebase, multiple platforms.",
            body,
        )
    )
    story.append(
        p(
            "Teaching point: initialize once in main; elsewhere use FirebaseAuth.instance, "
            "FirebaseFirestore.instance, FirebaseStorage.instance.",
            small,
        )
    )

    story.append(PageBreak())
    story.append(p("4. Authentication", h1))
    story.append(
        p(
            "<b>lib/widgets/auth_gate.dart</b> — Listens to authStateChanges(); "
            "signed in → Home, signed out → Login. Uses AuthFlowFlags so registration "
            "does not flash Home before sign-out.",
            body,
        )
    )
    story.append(
        p(
            "<b>lib/screens/auth/login_screen.dart</b> — signInWithEmailAndPassword; "
            "password reset email.",
            body,
        )
    )
    story.append(
        p(
            "<b>lib/screens/auth/register_screen.dart</b> — createUserWithEmailAndPassword; "
            "profile setup; then signOut so the user signs in manually.",
            body,
        )
    )
    story.append(
        p(
            "Reason: Auth provides uid used in Firestore paths like users/{uid}/....",
            small,
        )
    )

    story.append(p("5. Firestore — collections and code", h1))

    data = [
        ["Area", "Where in code", "Purpose"],
        [
            "products",
            "catalog_repository.dart, admin_panel_screen.dart",
            "Catalog; query active == true",
        ],
        [
            "banners",
            "catalog_repository.dart, admin_panel_screen.dart",
            "Promo slides; active filter",
        ],
        [
            "users/{uid}",
            "firebase_data_service.dart, profile_screen.dart",
            "Profile: email, displayName, phone, updatedAt",
        ],
        [
            "users/{uid}/favorites",
            "wishlist_provider.dart",
            "Wishlist doc id = productId",
        ],
        [
            "users/{uid}/orders",
            "checkout_screen.dart (write), orders_screen.dart (read)",
            "Orders after checkout; stream + orderBy createdAt",
        ],
    ]
    t = Table(data, colWidths=[1.15 * inch, 2.35 * inch, 2.5 * inch])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1A1D2E")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.whitesmoke),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.grey),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    story.append(t)
    story.append(Spacer(1, 10))
    story.append(
        p(
            "Reason: global collections for the store; per-user subcollections under users/{uid} "
            "match typical security rules (only that user writes their data).",
            body,
        )
    )
    story.append(
        p(
            "UI often uses snapshot streams for live updates when data changes in the console or admin.",
            small,
        )
    )

    story.append(p("6. Firebase Storage", h1))
    story.append(
        p(
            "<b>lib/services/firebase_data_service.dart</b> — uploadProfileImage: "
            "ref('users/{uid}/profile.jpg'), putData, getDownloadURL.",
            body,
        )
    )
    story.append(
        p(
            "<b>lib/services/catalog_repository.dart</b> — _resolveImage: if imageUrl is empty, "
            "uses imagePath with Storage ref().getDownloadURL(); caches URLs in memory.",
            body,
        )
    )
    story.append(
        p(
            "Reason: large binaries belong in Storage; Firestore holds metadata and URLs or paths.",
            small,
        )
    )

    story.append(PageBreak())
    story.append(p("7. End-to-end flow (story)", h1))
    bullets = [
        "App starts → Firebase.initializeApp + options.",
        "AuthGate → Login or Home from Auth state.",
        "CatalogRepository → Firestore products & banners; Storage for image paths if needed.",
        "Register → Auth user + upsertUserProfile on users/{uid}; sign out → login manually.",
        "Wishlist → users/{uid}/favorites.",
        "Checkout → add order under users/{uid}/orders; Orders screen listens to that path.",
    ]
    for b in bullets:
        story.append(p(f"• {b}", body))
        story.append(Spacer(1, 4))

    story.append(p("8. Security (conceptual)", h1))
    story.append(
        p(
            "The Flutter app calls Firebase APIs; <b>Firestore Security Rules</b> and "
            "<b>Storage Rules</b> in the Firebase Console enforce who can read/write. "
            "The data layout (users/{uid}/...) is designed to align with request.auth.uid.",
            body,
        )
    )

    story.append(p("9. Outside Dart (mention in lecture)", h1))
    story.append(
        p(
            "Android: google-services.json. iOS: GoogleService-Info.plist. "
            "These work together with firebase_options.dart from FlutterFire.",
            body,
        )
    )

    story.append(Spacer(1, 20))
    story.append(
        p(
            f"Generated for fashion_store_app project. File: {out.name}",
            small,
        )
    )

    doc.build(story)
    print(f"Wrote: {out}")


if __name__ == "__main__":
    main()
