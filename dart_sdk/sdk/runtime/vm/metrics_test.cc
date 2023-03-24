// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/assert.h"

#include "include/dart_api.h"
#include "include/dart_tools_api.h"

#include "vm/dart_api_impl.h"
#include "vm/dart_api_state.h"
#include "vm/globals.h"
#include "vm/json_stream.h"
#include "vm/metrics.h"
#include "vm/unit_test.h"
// #include "vm/heap.h"

namespace dart {

#if !defined(PRODUCT)
VM_UNIT_TEST_CASE(Metric_Simple) {
  TestCase::CreateTestIsolate();
  {
    Metric metric;

    // Initialize metric.
    metric.InitInstance(Isolate::Current(), "a.b.c", "foobar",
                        Metric::kCounter);
    EXPECT_EQ(0, metric.value());
    metric.increment();
    EXPECT_EQ(1, metric.value());
    metric.set_value(44);
    EXPECT_EQ(44, metric.value());
  }
  Dart_ShutdownIsolate();
}

class MyMetric : public Metric {
 protected:
  int64_t Value() const {
    // 99 bytes.
    return 99;
  }

 public:
  // Just used for testing.
  int64_t LeakyValue() const { return Value(); }
};

VM_UNIT_TEST_CASE(Metric_OnDemand) {
  TestCase::CreateTestIsolate();
  {
    Thread* thread = Thread::Current();
    TransitionNativeToVM transition(thread);
    StackZone zone(thread);
    MyMetric metric;

    metric.InitInstance(Isolate::Current(), "a.b.c", "foobar", Metric::kByte);
    // value is still the default value.
    EXPECT_EQ(0, metric.value());
    // Call LeakyValue to confirm that Value returns constant 99.
    EXPECT_EQ(99, metric.LeakyValue());

    // Serialize to JSON.
    JSONStream js;
    metric.PrintJSON(&js);
    const char* json = js.ToCString();
    EXPECT_STREQ(
        "{\"type\":\"Counter\",\"name\":\"a.b.c\",\"description\":"
        "\"foobar\",\"unit\":\"byte\","
        "\"fixedId\":true,\"id\":\"metrics\\/native\\/a.b.c\""
        ",\"value\":99.0}",
        json);
  }
  Dart_ShutdownIsolate();
}
#endif  // !defined(PRODUCT)

ISOLATE_UNIT_TEST_CASE(Metric_EmbedderAPI) {
  {
    TransitionVMToNative transition(thread);

    const char* kScript = "void main() {}";
    Dart_Handle api_lib = TestCase::LoadTestScript(
        kScript, /*resolver=*/nullptr, RESOLVED_USER_TEST_URI);
    EXPECT_VALID(api_lib);
  }

  // Ensure we've done new/old GCs to ensure max metrics are initialized.
  String::New("<land-in-new-space>", Heap::kNew);
  thread->heap()->CollectGarbage(thread, GCType::kScavenge,
                                 GCReason::kDebugging);
  thread->heap()->CollectGarbage(thread, GCType::kMarkCompact,
                                 GCReason::kDebugging);

  // Ensure we've something live in new space.
  String::New("<land-in-new-space2>", Heap::kNew);

  {
    TransitionVMToNative transition(thread);

    Dart_IsolateGroup isolate_group = Dart_CurrentIsolateGroup();
#if !defined(PRODUCT)
    EXPECT(Dart_VMIsolateCountMetric() > 0);
#endif
    EXPECT(Dart_IsolateGroupHeapOldUsedMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapOldUsedMaxMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapOldCapacityMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapOldCapacityMaxMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapNewUsedMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapNewUsedMaxMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapNewCapacityMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapNewCapacityMaxMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapGlobalUsedMetric(isolate_group) > 0);
    EXPECT(Dart_IsolateGroupHeapGlobalUsedMaxMetric(isolate_group) > 0);
  }
}

static uintptr_t event_counter;
static const char* last_gcevent_type;
static const char* last_gcevent_reason;

void MyGCEventCallback(Dart_GCEvent* e) {
  event_counter++;
  last_gcevent_type = e->type;
  last_gcevent_reason = e->reason;
}

ISOLATE_UNIT_TEST_CASE(Metric_SetGCEventCallback) {
  event_counter = 0;
  last_gcevent_type = nullptr;
  last_gcevent_reason = nullptr;

  {
    TransitionVMToNative transition(Thread::Current());

    const char* kScript = "void main() {}";
    Dart_Handle api_lib = TestCase::LoadTestScript(
        kScript, /*resolver=*/nullptr, RESOLVED_USER_TEST_URI);
    EXPECT_VALID(api_lib);
  }

  EXPECT_EQ(0UL, event_counter);
  EXPECT_NULLPTR(last_gcevent_type);
  EXPECT_NULLPTR(last_gcevent_reason);

  Dart_SetGCEventCallback(&MyGCEventCallback);

  GCTestHelper::CollectNewSpace();

  EXPECT_EQ(1UL, event_counter);
  EXPECT_STREQ("Scavenge", last_gcevent_type);
  EXPECT_STREQ("debugging", last_gcevent_reason);

  // This call emits 2 or 3 events.
  GCTestHelper::CollectAllGarbage(/*compact=*/ true);

  EXPECT_GE(event_counter, 3UL);
  EXPECT_STREQ("MarkCompact", last_gcevent_type);
  EXPECT_STREQ("debugging", last_gcevent_reason);
}

}  // namespace dart
