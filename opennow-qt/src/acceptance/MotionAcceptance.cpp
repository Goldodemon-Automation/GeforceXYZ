#include "acceptance/MotionAcceptance.h"
#include "app/AppController.h"

#include <QCoreApplication>
#include <QKeyEvent>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>
#include <QVariant>
#include <cmath>
#include <memory>

namespace {
QQuickItem *findItem(QQuickItem *item, const QString &name)
{
    if (!item) return nullptr;
    if (item->objectName() == name) return item;
    for (auto *child : item->childItems())
        if (auto *match = findItem(child, name)) return match;
    return nullptr;
}
struct Run {
    int tick = 0;
    bool sawIntermediate = false;
    double previous = 0;
    QPointer<QQuickItem> modal;
    QPointer<QQuickItem> motion;
    QPointer<QObject> page;
    QPointer<QQuickItem> surface;
};
}

void startSettingsMotionAcceptance(QQuickWindow *window, AppController *controller,
                                   const bool *qmlWarningOccurred, bool fullscreen)
{
    if (!window) { QCoreApplication::exit(1); return; }
    if (fullscreen) window->showFullScreen();
    struct State {
        int tick = 0;
        bool disclosureMoved = false, resolutionMoved = false, choiceMoved = false;
        bool sectionMoved = false, pageMoved = false;
        QPointer<QQuickItem> settings, disclosure, resolution, choice;
        double closedHeight = 0;
    };
    const auto state = std::make_shared<State>();
    auto *timer = new QTimer(window);
    timer->setInterval(20);
    QObject::connect(timer, &QTimer::timeout, window, [=] {
        const auto find = [window](const char *name) {
            return findItem(window->contentItem(), QString::fromLatin1(name));
        };
        const auto require = [=](bool ok, const char *message) {
            if (!ok) {
                qCritical("Settings motion tick %d: %s", state->tick, message);
                timer->stop(); QCoreApplication::exit(1);
            }
            return ok;
        };
        const auto intermediate = [](QQuickItem *item, const char *property) {
            const auto value = item ? item->property(property).toDouble() : 1.0;
            return value > 0 && value < 1;
        };
        const int tick = ++state->tick;
        if (!require(!*qmlWarningOccurred, "QML warning")) return;
        auto *outer = find("mainRouteLoader");
        if (!require(outer && outer->opacity() == 1, "page transition faded the entire shell")) return;
        if (!require(!fullscreen || window->visibility() == QWindow::FullScreen,
                     "transition changed fullscreen")) return;
        state->sectionMoved |= intermediate(find("settingsPageEntrance"), "progress");
        state->pageMoved |= intermediate(find("desktopPageEntrance"), "progress");
        state->disclosureMoved |= intermediate(state->disclosure, "revealProgress");
        state->resolutionMoved |= intermediate(state->resolution, "revealProgress");
        state->choiceMoved |= intermediate(state->choice, "revealProgress");
        if (controller->reducedMotion()
            && !require(!state->sectionMoved && !state->pageMoved && !state->disclosureMoved
                        && !state->resolutionMoved && !state->choiceMoved, "reduced motion animated")) return;
        if (tick == 1) controller->navigate(QStringLiteral("settings-account"));
        if (tick == 20) {
            state->settings = find("desktopSettingsScreen");
            auto *sharing = find("accountActivitySharing");
            auto *reports = find("accountCrashReports");
            state->disclosure = find("accountAdvancedDisclosure");
            if (!require(state->settings && !state->settings->property("advancedOpen").toBool()
                         && sharing && sharing->isVisible() && reports && reports->isVisible()
                         && state->disclosure, "privacy controls hidden behind Advanced")) return;
            // Only disclosure state is changed; never mutate privacy preferences.
            state->settings->setProperty("advancedOpen", true);
        }
        if (tick == 30 || tick == 36) state->settings->setProperty("advancedOpen", false);
        if (tick == 33) state->settings->setProperty("advancedOpen", true);
        if (tick == 55) {
            if (!require(state->disclosure->height() == 0 && !state->disclosure->isVisible(),
                         "Advanced did not finish closing")) return;
            state->settings->setProperty("selectedSection", 3);
        }
        if (tick == 60) {
            state->resolution = find("renewResolutionPicker");
            if (!require(state->resolution, "resolution picker missing")) return;
            state->closedHeight = state->resolution->height();
            state->resolution->setProperty("expanded", true);
        }
        if (tick == 66 || tick == 70) state->resolution->setProperty("expanded", false);
        if (tick == 68) state->resolution->setProperty("expanded", true);
        if (tick == 90) {
            if (!require(std::abs(state->resolution->height() - state->closedHeight) < 0.1
                         && state->resolution->property("revealProgress").toDouble() == 0,
                         "resolution reversal left incorrect bounds")) return;
            state->settings->setProperty("selectedSection", 8);
        }
        if (tick == 100) {
            state->choice = find("renewThemeChoice");
            if (!require(state->choice, "theme picker missing")) return;
            state->closedHeight = state->choice->height();
            state->choice->setProperty("expanded", true);
        }
        if (tick == 106 || tick == 140) state->choice->setProperty("expanded", false);
        if (tick == 108) state->choice->setProperty("expanded", true);
        if (tick == 130 && !require(state->choice->height() > state->closedHeight
                && state->choice->property("revealProgress").toDouble() == 1, "theme picker did not expand")) return;
        if (tick == 155) {
            if (!require(std::abs(state->choice->height() - state->closedHeight) < 0.1,
                         "theme picker did not collapse")) return;
            state->settings->setProperty("selectedSection", 5);
        }
        if (tick == 165 || tick == 185) {
            auto *shortcuts = find("renewShortcutsDisclosure");
            if (!require(shortcuts && QMetaObject::invokeMethod(shortcuts, "expansionRequested"),
                         "shortcuts disclosure missing")) return;
        }
        if (tick == 180) {
            auto *shortcuts = find("renewInlineShortcuts");
            if (!require(shortcuts && shortcuts->height() > 0, "shortcuts have no expanded height")) return;
        }
        if (tick == 205) controller->navigate(QStringLiteral("library"));
        if (tick == 208) controller->navigate(QStringLiteral("home"));
        if (tick == 230) {
            auto *page = find("desktopPageLoader");
            if (!require(page && page->opacity() == 1, "rapid navigation left a faded page")) return;
            if (!controller->reducedMotion()
                && !require(state->disclosureMoved && state->resolutionMoved && state->choiceMoved
                            && state->sectionMoved && state->pageMoved, "missing intermediate animation frames")) return;
            timer->stop(); QCoreApplication::exit(0);
        }
    });
    timer->start();
}

// The desktop chrome opens navigation as a drawer over the page: closed, it is
// parked off-canvas and the page owns the full window; open, it slides in from
// the same edge and settles flush with it. This runs the menu button through a
// full close/open/close cycle and checks the drawer never covers or shifts the
// page while it is closed.
void startSidebarAcceptance(QQuickWindow *window, AppController *controller,
                            const bool *qmlWarningOccurred, bool fullscreen)
{
    if (!window) { qCritical("Sidebar acceptance: no application window"); QCoreApplication::exit(1); return; }
    if (fullscreen) window->showFullScreen();
    auto *sidebar = findItem(window->contentItem(), QStringLiteral("desktopSidebar"));
    auto *menu = findItem(window->contentItem(), QStringLiteral("desktopHeaderMenu"));
    auto *host = findItem(window->contentItem(), QStringLiteral("desktopContentHost"));
    auto *home = findItem(window->contentItem(), QStringLiteral("sidebarIcon-home"));
    auto *library = findItem(window->contentItem(), QStringLiteral("sidebarIcon-library"));
    if (!sidebar || !menu || !host || !home || !library) {
        qCritical("Sidebar acceptance: fixture incomplete (drawer %d menu %d page %d home icon %d library icon %d)",
                  sidebar != nullptr, menu != nullptr, host != nullptr,
                  home != nullptr, library != nullptr);
        QCoreApplication::exit(1);
        return;
    }
    struct State {
        int tick = 0;
        int phase = 0;      // 0 settled closed, 1 opening or open, 2 closing, 3 finished
        int clickedAt = 0;
        double width = 0;
        QSizeF librarySize;
        bool intermediate = false;
        bool openChecked = false;
    };
    const auto state = std::make_shared<State>();
    const auto reveal = [sidebar] { return sidebar->property("reveal").toDouble(); };
    const auto closedAtRest = [sidebar] { return sidebar->x() <= -sidebar->width() + 0.5; };
    const auto flushWithEdge = [sidebar] { return std::abs(sidebar->x()) <= 0.5; };
    auto *timer = new QTimer(window);
    timer->setInterval(20);
    QObject::connect(timer, &QTimer::timeout, window, [=] {
        const int tick = ++state->tick;
        const auto fail = [timer](const char *message) {
            qCritical("Sidebar acceptance: %s", message);
            timer->stop(); QCoreApplication::exit(1);
        };
        const auto clickMenu = [menu, &fail] {
            if (!QMetaObject::invokeMethod(menu, "clicked")) {
                fail("navigation menu button did not respond");
                return false;
            }
            return true;
        };
        if (*qmlWarningOccurred) { fail("QML warning"); return; }
        if (tick == 15) {
            state->width = sidebar->width();
            state->librarySize = library->size();
            // Navigation is chrome, not layout: the page spans the whole window
            // whether the drawer is open or closed.
            if (std::abs(host->x()) > 0.5 || std::abs(host->width() - window->width()) > 0.5) {
                fail("page did not span the full window width"); return;
            }
            if (!menu->isVisible()) { fail("navigation menu button is hidden"); return; }
            // A pinned-open preference is closed first so the cycle always
            // starts from the parked state.
            state->clickedAt = tick;
            if (!closedAtRest() && !clickMenu()) return;
        }
        if (tick > 15) {
            const double progress = reveal();
            if (progress > 0 && progress < 1) state->intermediate = true;
            if (library->size() != state->librarySize) { fail("navigation icon resized"); return; }
            int libraryIcons = 0;
            const auto countLibraryIcons = [&](auto &&self, QQuickItem *item) -> void {
                if (item->objectName() == QStringLiteral("sidebarIcon-library")) ++libraryIcons;
                for (auto *child : item->childItems()) self(self, child);
            };
            countLibraryIcons(countLibraryIcons, sidebar);
            if (libraryIcons != 1) { fail("drawer duplicated the library icon"); return; }
            const bool settled = tick >= state->clickedAt + 4;
            if (state->phase == 0 && settled && progress == 0 && closedAtRest()) {
                if (home->mapToScene(QPointF{}).x() >= 0) {
                    fail("closed drawer left navigation over the page"); return;
                }
                state->phase = 1;
                state->clickedAt = tick;
                if (!clickMenu()) return;
            } else if (state->phase == 1 && settled && progress == 1 && flushWithEdge()) {
                if (!state->openChecked) {
                    if (!home->isVisible() || !library->isVisible()) {
                        fail("open drawer hid its navigation"); return;
                    }
                    const auto homeOrigin = home->mapToScene(QPointF{});
                    const auto libraryOrigin = library->mapToScene(QPointF{});
                    if (homeOrigin.x() < 0 || libraryOrigin.x() < 0
                        || libraryOrigin.x() + library->width() > state->width + 0.5
                        || libraryOrigin.y() <= homeOrigin.y()) {
                        fail("open drawer placed navigation outside its bounds"); return;
                    }
                    for (auto *ancestor = library; ancestor != sidebar; ancestor = ancestor->parentItem()) {
                        if (!ancestor || ancestor->opacity() != 1) {
                            fail("open drawer faded its navigation"); return;
                        }
                    }
                    state->openChecked = true;
                    state->phase = 2;
                    state->clickedAt = tick;
                    if (!clickMenu()) return;
                }
            } else if (state->phase == 2 && settled && progress == 0 && closedAtRest()) {
                if (std::abs(sidebar->width() - state->width) > 0.5) { fail("drawer changed width"); return; }
                if (!controller->reducedMotion() && !state->intermediate) {
                    fail("drawer did not animate"); return;
                }
                state->phase = 3;
                timer->stop(); QCoreApplication::exit(0);
            }
        }
        if (tick > 400) { fail("drawer never settled"); return; }
    });
    timer->start();
}

void startStoreNavigationAcceptance(QQuickWindow *window, const bool *qmlWarningOccurred)
{
    auto *page = findItem(window->contentItem(), QStringLiteral("desktopStoreContent"));
    auto *viewport = findItem(window->contentItem(), QStringLiteral("storeViewport"));
    auto *upper = findItem(window->contentItem(), QStringLiteral("storeShelf-new"));
    auto *motion = page ? page->findChild<QObject *>(QStringLiteral("storeScrollAnimation")) : nullptr;
    if (!page || !viewport || !upper || !motion) {
        qCritical("Store navigation fixture is incomplete");
        QCoreApplication::exit(1);
        return;
    }
    struct State { int tick = 0; double previous = 0; double hoverY = 0; };
    const auto state = std::make_shared<State>();
    auto *timer = new QTimer(window);
    timer->setInterval(40);
    QObject::connect(timer, &QTimer::timeout, window,
        [window, page, viewport, upper, motion, qmlWarningOccurred, timer, state] {
        const auto require = [timer, state](bool ok, const char *message) {
            if (!ok) {
                qCritical("Store navigation tick %d: %s", state->tick, message);
                timer->stop();
                QCoreApplication::exit(1);
            }
            return ok;
        };
        const auto select = [page](const char *zone) {
            return QMetaObject::invokeMethod(page, "selectZone",
                Q_ARG(QVariant, QVariant(QString::fromLatin1(zone))), Q_ARG(QVariant, QVariant(0)));
        };
        const auto key = [window](int code) {
            QKeyEvent press(QEvent::KeyPress, code, Qt::NoModifier);
            QCoreApplication::sendEvent(window, &press);
            QKeyEvent release(QEvent::KeyRelease, code, Qt::NoModifier);
            QCoreApplication::sendEvent(window, &release);
        };
        const auto y = [viewport] { return viewport->property("contentY").toDouble(); };
        const auto zone = [page] { return page->property("focusZone").toString(); };
        const int tick = ++state->tick;
        if (!require(!*qmlWarningOccurred, "QML warning")) return;
        if (tick == 1 && !require(select("popular"), "row navigation unavailable")) return;
        if (tick >= 2 && tick <= 8) {
            // Reproduce enter events caused by rows moving under a stationary
            // pointer, using the actual shelf signal wired by the production UI.
            if (motion->property("running").toBool())
                QMetaObject::invokeMethod(upper, "gamePointed", Q_ARG(int, 0));
            if (!require(zone() == QStringLiteral("popular"), "hover stole animated navigation")
                || !require(y() + 0.5 >= state->previous, "downward scroll reversed")) return;
            state->previous = y();
        }
        if (tick == 10) {
            if (!require(y() > 0 && !motion->property("running").toBool(), "row never settled")) return;
            state->hoverY = y();
            QMetaObject::invokeMethod(upper, "gamePointed", Q_ARG(int, 0));
            if (!require(zone() == QStringLiteral("new"), "hover selection no longer works")) return;
        }
        if (tick >= 11 && tick <= 18)
            if (!require(std::abs(y() - state->hoverY) < 0.5, "hover started scrolling")) return;
        // Real key delivery: reverse direction before the prior move finishes.
        if (tick == 20) key(Qt::Key_Up);
        if (tick == 21 || tick == 22) key(Qt::Key_Down);
        if (tick == 32) {
            if (!require(zone() == QStringLiteral("popular") && !motion->property("running").toBool(),
                         "rapid up/down did not settle on the requested row")) return;
            auto *row = findItem(window->contentItem(), QStringLiteral("storeShelf-popular"));
            const auto top = row ? row->mapToItem(viewport, QPointF{}).y() : -9999;
            if (!require(row && top >= -0.5 && top + row->height() <= viewport->height() + 0.5,
                         "selected row is outside the viewport")) return;
        }
        if (tick == 33) { key(Qt::Key_Up); key(Qt::Key_Up); key(Qt::Key_Up); }
        if (tick == 43 && !require(zone() == QStringLiteral("hero") && std::abs(y()) < 0.5,
                                  "up navigation did not return to the hero")) return;
        if (tick == 44) select("popular");
        if (tick == 45) {
            // Direct scrolling must take ownership from the focus animation.
            QMetaObject::invokeMethod(viewport, "movementStarted");
            viewport->setProperty("contentY", 87.0);
        }
        if (tick == 55) {
            if (!require(std::abs(y() - 87) < 0.5 && !motion->property("running").toBool(),
                         "animation fought manual scrolling")) return;
            timer->stop();
            QCoreApplication::exit(0);
        }
    });
    timer->start();
}

void startMotionAcceptance(QQuickWindow *window, AppController *controller,
                           const bool *qmlWarningOccurred, bool fullscreen)
{
    if (!window) { QCoreApplication::exit(1); return; }
    if (fullscreen) window->showFullScreen();
    const auto run = std::make_shared<Run>();
    auto *timer = new QTimer(window);
    timer->setInterval(30);
    QObject::connect(timer, &QTimer::timeout, window,
        [window, controller, qmlWarningOccurred, fullscreen, run, timer] {
        const auto find = [window](const char *name) {
            return findItem(window->contentItem(), QString::fromLatin1(name));
        };
        const auto require = [timer, run](bool condition, const char *message) {
            if (!condition) {
                qCritical("Motion acceptance tick %d: %s", run->tick, message);
                timer->stop();
                QCoreApplication::exit(1);
            }
            return condition;
        };
        ++run->tick;
        if (!require(!*qmlWarningOccurred, "QML warning during motion")) return;
        auto *outer = find("mainRouteLoader");
        if (!require(outer && outer->opacity() == 1, "navigation faded the entire shell/video")) return;
        if (!require(!fullscreen || window->visibility() == QWindow::FullScreen,
                     "overlay changed fullscreen state")) return;

        const int tick = run->tick;
        if (tick == 1) controller->navigate(QStringLiteral("home"));
        if (tick == 4) {
            run->modal = find("desktopGameModal");
            run->motion = find("gameDetailsMotion");
            auto *pageLoader = find("desktopPageLoader");
            if (!require(run->modal && run->motion && pageLoader, "missing retained modal/page")) return;
            run->page = pageLoader->property("item").value<QObject *>();
            controller->navigate(QStringLiteral("game-detail"));
        }
        if (tick >= 5 && tick <= 36) {
            auto *pageLoader = find("desktopPageLoader");
            if (!require(run->modal && run->motion && run->page && pageLoader
                    && pageLoader->property("item").value<QObject *>() == run->page,
                    "opening/closing details recreated the underlying page")) return;
            const double progress = run->motion->property("progress").toDouble();
            if (!require(std::isfinite(progress) && progress >= 0 && progress <= 1,
                         "reveal overshot its bounds")) return;
            run->sawIntermediate |= progress > 0 && progress < 1;
            if (!require((progress == 0 || run->modal->isVisible()), "popup hidden mid-transition")) return;
            if ((tick >= 6 && tick <= 7) || (tick >= 11 && tick <= 18))
                if (!require(progress + 0.001 >= run->previous, "opening jumped backwards")) return;
            if (tick == 9 || (tick >= 21 && tick <= 27))
                if (!require(progress <= run->previous + 0.001, "closing jumped forwards")) return;
            if (tick == 18 || tick == 36)
                if (!require(progress == 1, "reopened popup never settled")) return;
            if (tick == 27)
                if (!require(progress == 0 && !run->modal->isVisible(), "closed popup retained visibility")) return;
            run->previous = progress;
        }
        if (tick == 8 || tick == 19 || tick == 37) controller->goBack();
        if (tick == 10 || tick == 28) controller->navigate(QStringLiteral("game-detail"));
        if (tick == 38) {
            controller->navigate(QStringLiteral("stream"));
            run->surface = find("streamSurfaceHost");
        }
        if (tick >= 39) {
            auto *fallback = find("fallbackOverlayHost");
            if (!require(fallback && fallback->opacity() == 0,
                         "native overlay left a second dimming layer behind")) return;
            if (!require(run->surface && find("streamSurfaceHost") == run->surface,
                         "stream presenter was recreated by an overlay")) return;
            if (tick == 39 || tick == 43) controller->showOverlay(QStringLiteral("desktop-stream-menu"));
            if (tick == 41) controller->showOverlay(QString{});
            auto *motion = find("streamMenuMotion");
            if (!require(motion != nullptr, "missing stream menu motion")) return;
            if (tick == 53) {
                if (!require(motion->property("progress").toDouble() == 1, "stream menu failed to reopen")) return;
                // Invoke the real resume action, including its close completion.
                if (!require(QMetaObject::invokeMethod(motion->parent(), "runAction", Q_ARG(QVariant, QVariant(0))),
                             "resume action unavailable")) return;
            }
            if (tick == 62) {
                if (!require(controller->overlay().isEmpty() && motion->property("progress").toDouble() == 0,
                             "resume did not finish exactly after close")) return;
                controller->showOverlay(QStringLiteral("desktop-stream-exit-confirm"));
            }
            if (tick == 64) controller->showOverlay(QString{});
        }
        if (tick == 72) {
            if (!require(controller->reducedMotion() || run->sawIntermediate,
                         "normal mode snapped instead of animating")) return;
            if (!require(!controller->reducedMotion() || !run->sawIntermediate,
                         "reduced motion still animated")) return;
            timer->stop();
            QCoreApplication::exit(0);
        }
    });
    timer->start();
}
