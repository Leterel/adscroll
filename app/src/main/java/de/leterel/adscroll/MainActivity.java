package de.leterel.adscroll;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.view.GestureDetector;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public final class MainActivity extends Activity {
    private long position;
    private Pager pager;
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        position = state == null ? 0 : Math.max(0, state.getLong("position", 0));
        pager = new Pager();
        pager.setOnApplyWindowInsetsListener((view, insets) -> {
            view.setPadding(insets.getSystemWindowInsetLeft(), insets.getSystemWindowInsetTop(), insets.getSystemWindowInsetRight(), insets.getSystemWindowInsetBottom());
            return insets;
        });
        setContentView(pager); pager.requestApplyInsets(); pager.show();
    }
    @Override protected void onSaveInstanceState(Bundle state) { state.putLong("position", position); super.onSaveInstanceState(state); }
    @Override public boolean dispatchKeyEvent(KeyEvent event) {
        int code = event.getKeyCode();
        boolean forward = code == KeyEvent.KEYCODE_DPAD_DOWN || code == KeyEvent.KEYCODE_PAGE_DOWN;
        boolean backward = code == KeyEvent.KEYCODE_DPAD_UP || code == KeyEvent.KEYCODE_PAGE_UP;
        if (forward || backward) { if (event.getAction() == KeyEvent.ACTION_DOWN) pager.move(forward); return true; }
        return super.dispatchKeyEvent(event);
    }
    private int dp(int n) { return Math.round(n * getResources().getDisplayMetrics().density); }
    private TextView text(String value, int size, int color) {
        TextView text = new TextView(this); text.setText(value); text.setTextSize(size); text.setTextColor(color);
        text.setPadding(0, dp(8), 0, dp(8)); return text;
    }
    private final class Pager extends LinearLayout {
        private final GestureDetector gestures;
        private ScrollView cardScroll;
        private boolean couldScrollDown, couldScrollUp;
        Pager() {
            super(MainActivity.this); setOrientation(VERTICAL); setBackgroundColor(Color.rgb(17,19,18));
            setFocusable(true); setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_YES);
            gestures = new GestureDetector(MainActivity.this, new GestureDetector.SimpleOnGestureListener() {
                @Override public boolean onDown(MotionEvent event) { return false; }
                @Override public boolean onFling(MotionEvent from, MotionEvent to, float vx, float vy) {
                    if (from == null || to == null || Math.abs(to.getY()-from.getY()) < dp(48) || Math.abs(vy) < 150 || Math.abs(vy) <= Math.abs(vx)) return false;
                    if (to.getY() < from.getY() ? couldScrollDown : couldScrollUp) return false;
                    move(to.getY() < from.getY()); return true;
                }
            });
        }
        @Override public boolean dispatchTouchEvent(MotionEvent event) {
            if (event.getActionMasked() == MotionEvent.ACTION_DOWN) {
                couldScrollDown = cardScroll != null && cardScroll.canScrollVertically(1);
                couldScrollUp = cardScroll != null && cardScroll.canScrollVertically(-1);
            }
            boolean swipe = gestures.onTouchEvent(event);
            return super.dispatchTouchEvent(event) || swipe;
        }
        void move(boolean forward) {
            position = forward ? Catalog.next(position) : Catalog.previous(position); show();
            announceForAccessibility("Demo-Anzeige " + (position + 1));
        }
        void show() {
            removeAllViews();
            TextView brand = text("adscroll.     DEMO", 22, Color.WHITE); brand.setPadding(dp(24),dp(12),dp(24),dp(12)); addView(brand);
            String[] ad = Catalog.ADS[Catalog.index(position)]; int ink = Color.parseColor(ad[4]);
            ScrollView scroll = new ScrollView(MainActivity.this); scroll.setFillViewport(true); cardScroll = scroll;
            LinearLayout card = new LinearLayout(MainActivity.this); card.setOrientation(VERTICAL); card.setPadding(dp(28),dp(20),dp(28),dp(24)); card.setBackgroundColor(Color.parseColor(ad[3]));
            card.addView(text("FIKTIVE WERBUNG · KEINE ECHTE ANZEIGE", 11, ink));
            card.addView(text(ad[0], 17, ink));
            TextView mark = text("✳", 100, ink); mark.setGravity(android.view.Gravity.CENTER); mark.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO);
            card.addView(mark, new LinearLayout.LayoutParams(-1,0,1));
            card.addView(text(ad[1], 38, ink)); card.addView(text(ad[2], 16, ink));
            card.addView(text("DEMO / " + (position + 1) + "    ↑ Wischen für die nächste Anzeige", 12, ink));
            scroll.addView(card, new ScrollView.LayoutParams(-1,-1));
            addView(scroll, new LinearLayout.LayoutParams(-1,0,1));
        }
        @Override public void onInitializeAccessibilityNodeInfo(AccessibilityNodeInfo info) {
            super.onInitializeAccessibilityNodeInfo(info); info.setScrollable(true);
            info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_FORWARD);
            if (position > 0) info.addAction(AccessibilityNodeInfo.AccessibilityAction.ACTION_SCROLL_BACKWARD);
        }
        @Override public boolean performAccessibilityAction(int action, Bundle arguments) {
            if (action == AccessibilityNodeInfo.ACTION_SCROLL_FORWARD) { move(true); return true; }
            if (action == AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD) { move(false); return true; }
            return super.performAccessibilityAction(action, arguments);
        }
    }
}
